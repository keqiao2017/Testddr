# Testddr
Test DDR of K7  


### 操作步骤： 
1. programm device 
2. hot reset (shell: sudo ./HOT_RESET_PCIE.sh 2)
3. fresh device 
4. run ILA and reset VIO
5. write ddr address to slv_reg1 (shell: sudo ./reg_rw /dev/xdma0_user 0x4 w 0xaddr)
6. Set VIO (ILA meet trigger)
7. read the file set as check file (shell :`sudo ./dma64_from_device -d /dev/xdma0_c2h_0  -f checkfile.bin -s 100000 -a 0xaddr -c 1) 
8. run testddr.pl
