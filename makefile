# @file makefile
# @brief 多功能通用Makefile。可以生成动态库、静态库、可执行文件，导出头文件
# @author LJA
# @version 0.0.1
# @date 2012-11-11

##########################################################
#                    必须设置的变量                      
#
# 这些变量不能为空，否则Make时无法正常运行
#
##########################################################
#编译动作，
#  ar: 编译静态库  so: 编译动态库  app: 编译可执行文件
#  只能指定一个动作，ar so app只能选择一个
ACTION = app

#目标名称，最终得到目标的名称，如:
# 静态库可以指定名称为: libXXX.a
# 动态库可以指定名称为: libXXX.so
# 可执行文件可以指定名称为: main.exe
TARGET = pppoerandom.exe

#编译器 
CC = gcc 

#连接器
LD = ld

#归档,静态库
AR = ar

#源代码文件后缀，可以指定多个后缀
#    注意: 目前不会根据后缀的不同而采用不同的编译
#    SUFFIX将被排序去重
#    指编译当前目录下.SUFFIX文件
#    SUFFIX的值不能够使d和o，因为中间生成的会使用这两个后缀
# 例:c
SUFFIX = c
##########################################################
#                    可选的变量
#
# 这些变量根据实际的需求进行设置，如果为空，使用默认值
#
##########################################################
#最终目标被复制到指定放置的路径，可以指定多个路径
#当前目录下会一直保存一份目标文件
#例:TARGET_DIR1 TARGET_DIR2
TARGET_DIR = 

#头文件导出
#将$(EXPORT_HEAD)中指定的头文件复制到$(EXPORT_HEAD)目录中
#    如果$(EXPORT_HEAD)不为空，$(EXPORT_HEAD_DIR)为空，提示error
#    如果$(EXPORT_HEAD)为空，$(EXPORT_HEAD_DIR)为空，不做操作
#    如果$(EXPORT HEAD_DIR)中有多个目录，头文件被复制到其中的每一个目录下
#    EXPORT_HEAD和EXPORT_HEAD_DIR将被排序去重
EXPORT_HEAD = 
EXPORT_HEAD_DIR =

#编译选项
CFLAGS = 

#在$(CC)中使用的连接选项
#    当前的链接过程使用的是$(CC),由$(CC)自行调用链接器进行链接
#    一般情况下，这样已经足够了
#    以后如果有需要，改成直接使用$(LD)进行链接的方式
LDFLAGS =

#中间文件存放路径，默认为当前路径，只能指定一个路径
#例:obj
OBJ_DIR = obj

#头文件路径，可以指定多个路径，当前路径始终包含在内
#例: ../include
HEAD_DIR =  ../ljac/include/

#连接库路径
#例: ../lib 
LIB_DIR = ../ljac/lib/
#动态连接库,
#例m
DY_LIB = 
#静态连接库,
#例:cunit
ST_LIB = ljac

#进入其中执行Make的子目录
#    如果指定了子目录，首先按照指定的顺序到子目录下执行make
#    可以指定多个目录，如果目录重复出现，那么每遇到一次就会进入执行一次
#    为了防止无限的循环Make，这里只允许当前路径下目录,只允许如下样式的目录
#        aaa 或者 aaa/
#
#    当前目录中目标的编译在子目录中的Make完成后进行
#    当前Makefile中的变量不会传递到子Makefile中
#
#    虽然需要在每个子目录中设置Makefilek看起来似乎有些麻烦
#    但我认为这样是有必要的，这样我们可以掌控每个Make的行为
SUB_MAKE_DIR = 

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#     实现部分！
#
#     除非知道正在做什么，否则不要修改接下来的任意一个字符!
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

##########################################################
#                   自定义函数
#
# 通过shell完成 
#
##########################################################
#检查目录是否存在，如果存在返回空，否则返回不为空
define check_dir
$(shell if [ -d $1 ];then echo;else echo 1;fi)
endef

#检查$1中的值$2所指向的目录是否存在，如果存在返回，否则提示然后立即退出
# 例:
# $(call check_dir2,DIR,xxx) 
# 检查xxx(xxx是变量DIR值中的一个词)目录是否存在，如果不存在，提示:
#   DIR's value (xxx) does not exist!
define check_dir2
$(if $(call check_dir,$2),$(error "$1's value ($2) does not exist!"),)
endef

#检查文件是否存在，如果存在返回空，否则返回不为空
define check_file
$(shell if [ -e $1 ];then echo;else echo 1;fi)
endef

#检查$1中的值$2所指向的文件是否存在，如果存在返回，否则提示然后立即退出
# 例:
# $(call check_file2,FILE,xxx) 
# 检查xxx(xxx是变量FILE值中的一个词)文件是否存在，如果不存在，提示:
#   FILE's value (xxx) does not exist!
define check_file2
$(if $(call check_file,$2),$(error "$1's value ($2) does not exist!"),)
endef

#生成一个变量obj-XX,其中存放当前目录下所有已XX为后缀的文件
#  在DIR目录下对应的.o文件
#例:  $(call set_obj_x,c,DIR)
#  定义了obj-c=DIR/XXX.o
define set_obj_x
obj-$1 = $(patsubst %.$1,$2/%.o,$(wildcard *.$1))
endef

##########################################################
#                   变量检查
#
# 检查设置的变量是否正确
#
##########################################################
CC := $(strip $(CC))
ifeq ($(CC),)
$(error "CC is not set!")
endif

LD := $(strip $(LD))
ifeq ($(LD),)
$(error "LD is not set!")
endif

AR := $(strip $(AR))
ifeq ($(AR),)
ifeq ($(ACTION),ar)
$(error "AR is not set!")
endif
endif

SUFFIX := $(strip $(SUFFIX))
SUFFIX := $(sort $(SUFFIX))
ifeq ($(SUFFIX),)
$(error "SUFFIX is not set!")
endif
ifeq ($(SUFFIX),d)
$(error "SUFFIX's value (d) is invalid!")
endif
ifeq ($(SUFFIX),o)
$(error "SUFFIX's value (o) is invalid!")
endif

ACTION := $(strip $(ACTION))
ifeq ($(ACTION),)
$(error "ACTION is not set!")
endif
ifneq ($(words $(ACTION)),1)
$(error "ACTION's value is too many!")
endif
#$(error $(ACTION))
allact = ar so app
ifeq ($(allact),$(filter-out $(ACTION),$(allact)))
$(error "ACTION's value ($(ACTION)) is invalid!")
endif

TARGET := $(strip $(TARGET))
ifeq ($(TARGET),)
$(error "TARGET is not set!")
endif

CFLAGS := $(strip $(CFLAGS))

LDFLAGS := $(strip $(LDFLAGS))

OBJ_DIR := $(strip $(OBJ_DIR))
ifneq ($(words $(sort $(OBJ_DIR))),1)
$(error "OBJ_DIR's value is too many!")
endif
ifneq ($(call check_dir,$(OBJ_DIR)),)
$(error "OBJ's value ($(OBJ_DIR)) does not exist!")
endif

HEAD_DIR := $(strip $(HEAD_DIR))
ifneq ($(HEAD_DIR),)
$(foreach var,$(HEAD_DIR),$(call check_dir2,HEAD_DIR,$(var)))
endif

LIB_DIR := $(strip $(LIB_DIR))
ifneq ($(LIB_DIR),)
$(foreach var,$(LIB_DIR),$(call check_dir2,LIB_DIR,$(var)))
endif

DY_LIB := $(strip $(DY_LIB))
ST_LIB := $(strip $(ST_LIB))

TARGET_DIR := $(strip $(TARGET_DIR))
ifneq ($(TARGET_DIR),)
$(foreach var,$(TARGET_DIR),$(call check_dir2,TARGET_DIR,$(var)))
endif

EXPORT_HEAD := $(strip $(EXPORT_HEAD))
EXPORT_HEAD := $(sort $(EXPORT_HEAD))
EXPORT_HEAD_DIR := $(strip $(EXPORT_HEAD_DIR))
EXPORT_HEAD_DIR := $(sort $(EXPORT_HEAD_DIR))
ifneq ($(EXPORT_HEAD),)
$(foreach var,$(EXPORT_HEAD_DIR),$(call check_dir2,EXPORT_HEAD_DIR,$(var)))
$(foreach var,$(EXPORT_HEAD),$(call check_file2,EXPORT_HEAD,$(var)))
endif

SUB_MAKE_DIR := $(strip $(SUB_MAKE_DIR))
$(foreach var,$(SUB_MAKE_DIR),$(call check_dir2,SUB_MAKE_DIR,$(var)))

##########################################################
#                   根据配置生成需要的变量
#
#
#
##########################################################

#所有.SUFFIX文件
all_src = $(foreach i,$(SUFFIX),$(wildcard ./*.$(i)))

#定义了obj-X变量,x是SUFFIX中的值
$(eval $(foreach i,$(SUFFIX),$(call set_obj_x,$i,$(OBJ_DIR))))

#所有.SUFFIX文件对应的.o文件
all_obj = $(foreach i,$(SUFFIX),$(obj-$i))

#头文件路径
head_dir = $(foreach d,$(HEAD_DIR),-I$d)

#连接库路径
lib_dir = $(foreach d,$(LIB_DIR),-L$d)

#动态连接库
dy_lib	= $(foreach d,$(sort $(DY_LIB)),-l$d)

#静态连接库
st_lib	= $(foreach d,$(sort $(ST_LIB)),-l$d)

#最终的编译选项
cflags = $(head_dir) $(CFLAGS) 
#最终的连接选项
ldflags = $(lib_dir) -Wl,-Bstatic $(st_lib) -Wl,-Bdynamic $(dy_lib) $(LDFLAGS)
##########################################################
#                   开始编译
#
# 将所有.SUFFIX的文件先获取对应的依赖关系.d文件
# 然后编译成.o文件
# 最后将所有的.o文件连接成目标文TARGET
#
##########################################################
ifneq ($(EXPORT_HEAD),)
.PHONY = all $(TARGET) clean export
all: $(TARGET) export
else
.PHONY = all $(TARGET) clean
all: $(TARGET) 
endif

ifeq ($(ACTION),ar)    #静态库
$(TARGET):$(all_obj)
	for d in $(SUB_MAKE_DIR);do make -C $$d; done;
	$(AR) rcvs $@ $^
	for i in $(TARGET_DIR);do if [ -d $$i ];then cp $@ $$i;fi;done
endif

ifeq ($(ACTION),so)    #动态库
cflags += -fpic -shared
ldflags += -shared
$(TARGET): $(all_obj)
	for d in $(SUB_MAKE_DIR);do make -C $$d; done;
	$(CC) $^ -o $@ $(ldflags) 
	for i in $(TARGET_DIR);do if [ -d $$i ];then cp $@ $$i;fi;done
endif

ifeq ($(ACTION),app)    #应用程序
$(TARGET): $(all_obj)
	for d in $(SUB_MAKE_DIR);do make -C $$d; done;
	$(CC) $^ -o $@ $(ldflags) 
	for i in $(TARGET_DIR);do if [ -d $$i ];then cp $@ $$i;fi;done
endif

ifneq ($(EXPORT_HEAD),)
export: $(EXPORT_HEAD)
	for i in $(EXPORT_HEAD); do for d in $(EXPORT_HEAD_DIR);do cp -rf $$i $$d;echo $$i;echo $$d; done;done
endif
clean:
	rm -f $(OBJ_DIR)/*.o  $(OBJ_DIR)/*.d  $(TARGET)

#obj文件生成规则
#  cmd_o   文件后缀  obj文件存放的路径
#  $(call cmd_o,c,obj)第一次展开后:
#  MAKEFIL_LIST是make的内置变量,是make读取的文件的列表
#  这样确保了Makefile被修改后也会进行重新编译
#$(obj-c): obj%.o:%.c MAKEFILE_LIST
#	CC cflgs -Wp,-MT,$@ -Wp,-MMD,$@.d -c -o $@ $<
#  这里的目标文件使用了Makefile的静态模式，可以指定多个目标
#  obj%.o:%.c说明了每一个目标文件的依赖关系
define cmd_o
$$(obj-$1): $2/%.o:%.$1 $(MAKEFILE_LIST)
	$(CC) $(cflags) -Wp,-MT,$$@ -Wp,-MMD,$$@.d -c -o $$@ $$<
endef
#给出了obj-(SUFIX)分别对应的编译规则
$(eval $(foreach i,$(SUFFIX),$(call cmd_o,$i,$(OBJ_DIR))))

-include $(patsubst %.o,%o.d,$(all_obj))
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#     检查清单!
#
#     通过以下步骤检查这个Makefile是否工作正常
#
#       如果通过了以下的检查，基本就可以正常工作
#       在实际使用中发现问题,将进行校正
#
#     1 没有给CC赋值，提示 "CC is not set!"，然后立即退出
#     2 没有给LD赋值，提示 “LD is not set!"，然后立即退出
#     3 没有给SUFFIX赋值，提示 “SUFFIX is not set!"，然后立即退出
#     4 SUFFIX的值是d或者o，提示:
#       ”SUFFIX's value (d) is invalid!"
#       ”SUFFIX's value (o) is invalid!"
#     5 没有给ACTION赋值，提示 ”ACTION is not set!"，然后立即退出
#     6 ACTION的值中包含两种动作类型，提示 "ACTION's value is too many!"
#     7 没有给TARGET赋值，提示 ”TARGET is not set!"，然后立即退出
#     8 ACTION中包含ar so app以外的值，
#       提示 "ACTION's value (XXX) is invalid"
#     9 在OBJ_DIR中指定了一个以上不重复路径，
#       提示 "OBJ_DIR's value is more than one!"，然后立即退出
#    10 OBJ_DIR指定的目录不存在，提示＂OBJ's value(XXX) does not exist!'
#    11 HEAD_DIR指定的目录不存在，提示＂HEAD's value(XXX) does not exist!'
#    12 HEAD_DIR中指定目录XXX时，生成head_dir的值是-IXXX
#    13 LIB_DIR指定的目录不存在，提示＂LIB's value(XXX) does not exist!'
#    14 LIB_DIR中指定目录XXX时，生成lib_dir的值是-IXXX
#    15 EXPORT_HEAD不为空，且EXPORT_HEAD_DIR指定的目录不存在，
#       提示"EXPORT_HEAD_DIR's value(XXX) does not exist!"
#    16 EXPORT_HEAD中指定的文件不存在，
#       提示"EXPORT_HEAD' value (XXX) does not exist!"
#    17 如果SUB_MAKE_DIR指定的目录不存在，
#       提示"SUB_MAKE_DIR's value (XXX)does not exist!"
#    18 检查all_src中是否包含了当前目录下所有以SUFFIX中的值为后缀的文件名
#    19 检查all_obj中是否包含了当前目录下所有以SUFFIX中的值为后缀的文件名
#       在OBJ目录下对应的.o文件
#    20 指定了SUB_MAKE_DIR,子Make先执行
#    21 CFLAGS DY_LIB ST_LIB HEAD_DIR 都被包含在了cflags中
#    22 OBJ目录下生成.SUFFIX对应的.o文件，和.o的依赖文件.o.d
#    23 EXPORT_HEAD中的文件被导出到EXPORT_HEAD_DIR中的每一个目录
#    24 TARGET中的文件生成并被复制到了TARGET_DIR中
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
