# lab05 : Unidad de suma, resta, multiplicación, división y visualización BCD

## Integrantes 

- David Ariza

- Juan Rubiano

- Julian Villalobos

- Ronneth Briceño


## Introducción

En el presente laboratorio se abordan la sección inicial para realizar proyectos en la materia Digital II, especificamente para comprender el funcionamiento de la FPGA facilitada por la universidad. En este caso el trabajo consiste en implementar una unidad logica aritmetica (ALU) con funciones de suma, resta, multiplicación y división, además de la visualización de los resultados en los displays 7-segmentos presentes en la fpga.

Cabe destacar que en este archivo README se hace la documentación de trabajo realizado, es decir, de las modificaciones al multiplicador, del restador, divisor y la respectiva implementación en la ALU, además de la visualización en la FPGA fisica.


## Descripción modulos
### MULTIPLICADOR
Para realizar el multiplicador se hizo uso del archivo ya existente proporcionado por el docente. Se hicieron algunos cambios debido a que al momento de implementar en la tarjeta se presentaban fallos, tales como una respuesta errónea a la salida, se presentaba la repuesta un LED a la izquierda. Para corregir esto se hizo un cambio en la sección del datapath, cambiando el momento de ejecutarse de posedge a negedge, ya que si se ejectuaba al tiempo con la máquina de estados, se presentaba una superposición que generaba el fallo mencionado. Este cambio igualmente se pudo haber realizado en la máquina de estados, el único fin es lograr que cada sección se ejecute en un flanco diferente.

``` verilog
always @(negedge clk) begin 
  if (rst) begin 
    A = {3'b000,MD};
    B = MR;
  end 
  else begin 
    if (sh) begin
     A = A << 1;
     B = B >> 1;
    end
  end
end
```


### DIVISOR
Para el modulo divisor se crearon cuatro variables de entrada ```clk, init, DR, DV``` y una de salida `pp`, tambien se crean los diferentes registros que hacen posible los corriemientos y las operaciones necesarias para su funcionamiento, Luego de definir las variables se describe una maquina de estados finitos (FSM) la cual sigue los pasos realizados en clase segun explicacion del profesor. La descripcion completa de este hardware se encuentra [aqui](https://github.com/unal-edigital2/lab01-alu-grupo11/tree/master/alu/src/divisor).


``` verilog
module divisor(clk, init, DR, DV, pp);              

input clk; 
input init; 
input [2:0] DR;
input [2:0] DV; 
output reg [5:0] pp;

reg done;
reg sh;
reg rst;
reg add;
reg llenar;
reg asg;
reg [5:0] C;
reg [2:0] B;

reg [1:0] count;

wire z;

reg [2:0] status = 0;
```
### RESTADOR
El modulo restador se realizo de igual forma, creando las variables de entrada y de salida, para este caso se solicito que la entrada `xi` sea mayor que la entrada `yi`, luego se crea un registro llamado `yi_comp` el cual es el complemento y se le suma uno para hacerlo en complemento a dos, entonces gracias a la instruccion always cuando hay un cambio en las variables de entrada `xi` y el complemento a dos de `yi` se suman dando el resultado de la resta.

``` verilog
module resta(init, xi, yi, sal);

  input init;
  input [2:0] xi;
  input [2:0] yi;
  output [5:0] sal;
  
  reg [2:0] resultado;
  wire [2:0] yi_comp;
  
  assign yi_comp = ~yi+1;
  assign sal = {3'b000,resultado};
  
always @(*) begin
    if(xi >= yi )begin
        if(init) resultado = xi+yi_comp;
        else resultado=0;
    end
    else resultado = 0;
end
endmodule
```


## ALU
Para la implementación de la ALU se empezó por crear las variables necesarias, iniciando por las entradas requeridas ```port A```y ```port B```, después se debe elegir la operación a realizar, para esto se tiene la variable ```opcode```. Finalmente se agrega las variables de visualización ```sseg``` y ```an``` que nos ayudarán a ver el resultado en el 7 segmentos, el cual será controlado por la señal de reloj la cual se debe agregar ```clk```. 

``` verilog
module alu(
    input [2:0] portA,
    input [2:0] portB,
    input [1:0] opcode,
    output [0:6] sseg,
    output [4:0] an,
    input clk,
    input rst
 );

```

Luego de tener definidas las variables, se deben declarar las salidas de los bloques con sus señales de inicio, para poder obtener la respuesta de que operación se quiere llevar a cabo por medio del decodificador. Esto se hará con el siguiente código que muestra que init se activa con cada selección del case.

``` verilog
always @(*) begin
	case(opcode) 
		2'b00: init<=1;
		2'b01: init<=2;
		2'b10: init<=4;
		2'b11: init<=8;
	default:
		init <= 0;
	endcase
	
end

```

Después de esto se pasa a la etapa del mutiplexor, donde se elegirá la señal de salida que se observará en e display, dependiendo del valor escogido en ```opecode```. 

``` verilog
always @(*) begin
	case(opcode) 
		2'b00: int_bcd <={8'b00,sal_suma};
		2'b01: int_bcd <={8'b00,sal_resta};
		2'b10: int_bcd <={8'b00,sal_mult};
		2'b11: int_bcd <={8'b00,sal_div};
	default:
		int_bcd <= 0;
	endcase
	
end


```  

Luego de establecer todas las variables en la ALU, se deben referenciar los bloques de cada operación con el decodificador y el multiplexor, asignandole las entradas correspondientes.A

```verilog
sum4b sum( .init(init_suma),.xi({1'b0,portA}), .yi({1'b0,portB}),.sal(sal_suma));
restador res( .init(init_resta), .xi(portA), .yi(portB), .neg(sal_resta[4]), .sal(sal_resta[3:0]));
multiplicador mul ( .MR(portA), .MD(portB), .init(init_mult),.clk(clk), .pp(sal_mult));
BCDtoSSeg dp( .BCD(int_bcd), .SSeg(sseg));



```
 
