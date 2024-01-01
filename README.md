# FPGA
Various FPGA projects and libraries

## IEEE754 SP (Single Precision) floating point (f32) IPs:
**ieee754_f32_add_ip       :** f32 Adder IP to add two IEEE754 SP numbers<br />
**ieee754_f32_mult_ip      :** f32 Multiplier IP to multiply two IEEE754 SP numbers<br />
**ieee754_f32_div_ip       :** f32 Divider IP to divide two IEEE754 SP numbers<br />
**ieee754_f32_neg_ip       :** f32 Negate IP to compute opposite sign of IEEE754 SP number<br />
**ieee754_f32_cpx_add_ip   :** f32 Complex Adder IP to add two **complex** IEEE754 SP numbers<br />
**ieee754_f32_cpx_mult_ip  :** f32 Complex Multiplier IP to multiply two **complex** IEEE754 SP numbers<br />
**ieee754_f32_cpx_neg_ip   :** f32 Complex Negate IP to compute opposite sign of **complex** IEEE754 SP number<br />
**ieee754_f32_FFT8_ip      :** f32 FFT8 IP to compute FFT of 8 IEEE754 SP inputs [x0, x1, .., x7]<br /> 
**bin_divider_ip :** Binary Divider IP to divide two 32bit **binary** numbers. <br />

You can find further information by reading related documents that I put inside the **doc** folder.

After you download the library folder on your computer, you can add the folder as your IP repository through the Setting->IP in Vivado to be able to use them in your board-design.
![image](https://github.com/turalevent/FPGA/assets/22763063/7a51a3e2-376b-4bd6-b217-be6465200d68)
