# --------------------------------------------------------------------------
#
#	FILE NAME:		Makefile
#   AUTHOR:			Microsemi
#	DESCRIPTION:	Top level make file. 
#
# --------------------------------------------------------------------------
export SHELL=/bin/bash
SDKDIRS := vproc_sdk
export ROOTDIR=$(PWD)/$(SDKDIRS)
include config.mk

.PHONY: all $(SDKDIRS) cleanall clean install_sub install_sdk avs_git sensory_git host alexa start_alexa

MSCC_MOD_NAMES =  $(MSCC_HBI_MOD) $(MSCC_SND_COD_MOD) $(MSCC_SND_MAC_MOD) 
MSCC_DTB_NAMES =  $(MSCC_SPI_DTB) $(MSCC_SPIMULTI_DTB) $(MSCC_DAC_OVERLAY_DTB)

# make all command without arguments will run this
# 1- Download kernel headers and install them if not already done
# 2  compile the vproc_sdk
# 3- install the SDK and apps into the host
# 4- get alexa sample apps and install it
# 5- configure the ALSA sound card for the host
all: pi_kheaders vproc_sdk install_sdk avs_git alexa_install soundcfg message 

# make command without arguments will run this
# 1- Download kernel headers and install them if not already done
# 2 compile the vproc_sdk
# 3- install the SDK and apps into the host
# 4- configure the ALSA sound card for the host
host: pi_kheaders vproc_sdk install_sdk soundcfg message

vproc_sdk: $(SDKDIRS) 

$(SDKDIRS): 
	$(MAKE) -C $@ vproc_sdk 

# get alexa, install it and configure the ALSA sound card accordingly	
alexa: avs_git alexa_install soundcfg

start_alexa: alexa_exec
	

# undo everything done by the make all
cleanall: cleanmod_sub cleanov_sub cleansnd_sub cleanprof_sub cleanrc_sub cleanboot_sub cleanmodcfg_sub 
	rm -rf $(INSTALL_MSCC_LOCAL_LIB_PATH)
	rm -rf $(AMAZON_AVS_LOCAL_DIR)
	$(MAKE) -C $(ROOTDIR) clean 

#clean: same as cleanall but without the amazon_avs removal
#however don't remove the amazon_avs folder
clean: cleanmod_sub cleanov_sub cleansnd_sub cleanprof_sub cleanrc_sub cleanboot_sub cleanmodcfg_sub
	$(MAKE) -C $(ROOTDIR) clean 


#install the executable and modify appropriate files
install_sdk: install_sub modcfg_edit modcfg_cp bootcfg_edit startupcfg
	@echo "Compilation completed successfully...." 


avs_git:
	sudo apt-get install -y git
	@if [ ! -d  $(AMAZON_AVS_LOCAL_DIR) ]; then (mkdir $(AMAZON_AVS_LOCAL_DIR)); (git clone $(AMAZON_AVS_ONLINE_REPOSITORY) $(AMAZON_AVS_LOCAL_DIR)); fi

release: release_sub

swig:
	$(MAKE) -C $(ROOTDIR)/../apps/python/wrapper
	
help:
	@echo "-----------------------------------------------------------------------------------------------" 
	@echo "| SHELL="$(SHELL) 
	@echo "| ROOTDIR="$(ROOTDIR) 
	@echo "| SDKDIRS="$(SDKDIRS) 
	@echo "| MODDIRS="$(INSTALL_MSCC_MOD_DIR)
	@echo "| OVERLDIRS="$(INSTALL_MSCC_OVERLAYS_DIR)
	@echo "| APPSDIRS="$(INSTALL_MSCC_APPS_PATH)
	@echo "| USERDIR="$(HOST_USER_HOME_DIR)
	@echo "| USERPROFILE="$(HOST_USER_PROF_START_CFG_FILE_PATH)
	@echo "| USER:GROUP="$(platformUser):$(platformGroup)
	@echo "| To compile the Microsemi Voice Processing SDK: make vproc_sdk or make"
	@echo "| To compile the SDK, comfigure the host to bootup with the SDK driver/apps, download/compile Amazon Alexa : make all"
	@echo "| To compile the SDK, and comfigure the host to bootup with the SDK driver/apps : make host"
	@echo "| To undo everything done by the SDK compilation and install (Amazon alexa is not removed): make clean"
	@echo "| To undo everything done by make all compilation: make cleanall"
	@echo "-----------------------------------------------------------------------------------------------" 
	
