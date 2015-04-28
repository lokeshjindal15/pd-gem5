cmd_drivers/gpio/built-in.o :=  arm-linux-gnueabi-ld -EL    -r -o drivers/gpio/built-in.o drivers/gpio/devres.o drivers/gpio/gpiolib.o drivers/gpio/gpiolib-of.o 
