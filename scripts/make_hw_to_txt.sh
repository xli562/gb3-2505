# pwd = docker:/gb3-2505/hardware/rtl
make hw=processor 2>&1 | tee ../../data/$(date +%Y%m%d-%H-%M-%S)_out.txt
sudo chmod 777 ../../data/*out.txt