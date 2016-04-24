# linkit-smart-7688-golang

Build static binary using [golang](https://golang.org/) for linkit smart 7688.

## What's MT7688

802.11n 1T1R Wi-Fi AP SoC, Home Automation Bridge. Please refer to detail information abount [linkit smart 7688](http://www.mediatek.com/en/products/connectivity/wifi/home-network/wifi-ap/mt7688ka/).

## Installation

Please follow the [linkit smart 7688 feed](https://github.com/MediaTek-Labs/linkit-smart-7688-feed) instructions or using the docker as below:

```bash
$ git clone https://github.com/appleboy/linkit-smart-7688-golang.git
$ cd linkit-smart-7688-golang && docker build -t mt7688 .
```

Start the `7688` terminal.

```bash
$ docker run -ti --name 7688 mt7688 /bin/bash
```

## Update Source Code

open `package/libs/toolchain/Makefile` file

find

```makefile
define Package/ldd
```

insert before

```makefile
define Package/libgo
$(call Package/gcc/Default)
  TITLE:=Go support library
  DEPENDS+=@INSTALL_GCCGO
  DEPENDS+=@USE_EGLIBC
endef

define Package/libgo/config
       menu "Configuration"
               depends EXTERNAL_TOOLCHAIN && PACKAGE_libgo

       config LIBGO_ROOT_DIR
               string
               prompt "libgo shared library base directory"
               depends EXTERNAL_TOOLCHAIN && PACKAGE_libgo
               default TOOLCHAIN_ROOT  if !NATIVE_TOOLCHAIN
               default "/"  if NATIVE_TOOLCHAIN

       config LIBGO_FILE_SPEC
               string
               prompt "libgo shared library files (use wildcards)"
               depends EXTERNAL_TOOLCHAIN && PACKAGE_libgo
               default "./usr/lib/libgo.so.*"

       endmenu
endef
```

find

```makefile
define Package/libssp/install
```

insert before

```makefile
  define Package/libgo/install
        $(INSTALL_DIR) $(1)/usr/lib
        $(if $(CONFIG_TARGET_avr32)$(CONFIG_TARGET_coldfire),,$(CP) $(TOOLCHAIN_DIR)/lib/libgo.so.* $(1)/usr/lib/)
  endef
```

find

```makefile
$(eval $(call BuildPackage,ldd))
```

insert before

```makefile
$(eval $(call BuildPackage,libgo))
```

open `toolchain/gcc/Config.in` file. Insert the following code to bottom:

```makefile
config INSTALL_GCCGO
    bool
    prompt "Build/install gccgo compiler?" if TOOLCHAINOPTS && !(GCC_VERSION_4_6 || GCC_VERSION_4_6_LINARO)
    default n
    help
        Build/install GNU gccgo compiler ?
```

open `toolchain/gcc/common.mk` file.

find

```makefile
TARGET_LANGUAGES:="c,c++$(if $(CONFIG_INSTALL_LIBGCJ),$(SEP)java)$(if $(CONFIG_INSTALL_GFORTRAN),$(SEP)fortran)"
```

replace

```makefile
TARGET_LANGUAGES:="c,c++$(if $(CONFIG_INSTALL_LIBGCJ),$(SEP)java)$(if $(CONFIG_INSTALL_GFORTRAN),$(SEP)fortran)$(if $(CONFIG_INSTALL_GCCGO),$(SEP)go)"
```

Prepare the kernel configuration to inform OpenWrt that we want to build an firmware for LinkIt Smart 7688:

```bash
$ make menuconfig
```

Select the options as below:

* Target System: Ralink RT288x/RT3xxx
* Subtarget: MT7688 based boards
* Target Profile: LinkIt7688

Build [gccgo](https://golang.org/doc/install/gccgo):

```
-> Advanced configuration options
-> Toolchain options
-> Select Build/Install gccgo
-> C library implementation
-> Use eglibc
```

Start the compilation process:

```bash
$ make V=s
```

## Write your first golang program

Add an alias with your toolchain path information. This keeps it easy to call gccgo.

```bash
alias mips_gccgo='/root/openwrt/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_glibc-2.19/bin/mipsel-openwrt-linux-gccgo -Wl,-R,/root/openwrt/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_glibc-2.19/lib/gcc/mipsel-openwrt-linux-gnu/4.8.3 -L /root/openwrt/staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_glibc-2.19/lib'
```

helloworld.go

```go
package main

import "fmt"

func main() {
  fmt.Println("hello world")
}
```

build your go program

```bash
mips_gccgo -Wall -o helloworld_static_libgo helloworld.go -static-libgo
```

run your program on 7688 device

```bash
root@mylinkit:/tmp/7688# ./helloworld_static_libgo
hello world
```
