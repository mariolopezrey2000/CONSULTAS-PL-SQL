1./* Crea un procedimiento que a través del parámetro DEPT_NO de un departamento muestre: 
el número de departamento, su nombre y su localidad, así como el número de empleados que trabajan en ese departamento.
 Gestiona excepciones. */
CREATE OR REPLACE PROCEDURE EJER_8_1(p_dept_no number)
AS
V_DNOMBRE depart.dnombre%type;
V_LOC depart.loc%type;
NUM_EMPLE NUMBER(3);
BEGIN
SELECT DNOMBRE,LOC,COUNT(APELLIDO) into V_DNOMBRE,V_LOC,NUM_EMPLE 
FROM DEPART D,EMPLE E 
WHERE E.DEPT_NO =D.DEPT_NO AND D.DEPT_NO=p_dept_no 
GROUP BY DNOMBRE,LOC;
dbms_output.put_line(p_dept_no||' '||v_DNOMBRE||' '||v_LOC||' '||num_emple);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('no existe datoos');
    WHEN OTHERS THEN 
    dbms_output.put_line('error general');
end EJER_8_1;

execute ejer_8_1(30);

2./* Pasando el Dept_no como parámetro calcula para cada oficio el número de empleados que tiene, puede salir 0.
 Observación: Dado que sólo tenemos cursores implícitos no podemos tener mas de una respuesta por cada consulta  necesitamos 
 una consulta distinta para contar cada uno de los oficios. Gestiona también las excepciones. */
CREATE OR REPLACE PROCEDURE EJER_REF_8_2(DEP NUMBER)
AS
V_ANALISTA NUMBER(2);
V_EMPLEADO NUMBER(2);
V_PRESIDENTE NUMBER(2);
V_DIRECTOR NUMBER(2);
V_VENDEDOR NUMBER(2);
BEGIN
SELECT COUNT(*) INTO V_ANALISTA FROM EMPLE 
     WHERE DEPT_NO = DEP AND OFICIO = 'ANALISTA';
SELECT COUNT(*) INTO V_EMPLEADO FROM EMPLE 
     WHERE DEPT_NO = DEP AND OFICIO = 'EMPLEADO';
SELECT COUNT(*) INTO V_PRESIDENTE FROM EMPLE 
     WHERE DEPT_NO = DEP AND OFICIO = 'PRESIDENTE';
SELECT COUNT(*) INTO V_DIRECTOR FROM EMPLE 
     WHERE DEPT_NO = DEP AND OFICIO = 'DIRECTOR';
SELECT COUNT(*) INTO V_VENDEDOR FROM EMPLE 
     WHERE DEPT_NO = DEP AND OFICIO = 'VENDEDOR';

DBMS_OUTPUT.PUT_LINE(rpad('Vendedores: ', 15)||v_vendedor);
DBMS_OUTPUT.PUT_LINE(rpad('Directores: ', 15)||v_director);
DBMS_OUTPUT.PUT_LINE(rpad('Analistas: ', 15)||v_analista);
DBMS_OUTPUT.PUT_LINE(rpad('Empleados: ', 15)||v_empleado);
DBMS_OUTPUT.PUT_LINE(rpad('Presidente: ', 15)||v_presidente);

EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('ERROR');

end ejer_ref_8_2;

begin
 ejer_ref_8_2(30);
end;


3.	/* Crea un procedimiento que al recibir el nombre de un fabricante nos muestra la facturación de ese fabricante,
 tanto en nº de pedidos como en facturación, es decir: precio_venta*unidades_pedidas. */
 

CREATE OR REPLACE PROCEDURE EJER_8_2(nombrefabricante varchar2)
AS
V_FABRICANTE fabricantes.cod_fabricante%type;
v_numpedidos NUMBER(3);
V_facturacion number(6);
BEGIN
SELECT  F.COD_FABRICANTE,COUNT(P.ARTICULO),SUM(PRECIO_VENTA*UNIDADES_PEDIDAS) FACTURACION into v_fabricante,v_numpedidos,V_facturacion FROM FABRICANTES F,ARTICULOS A,PEDIDOS P 
WHERE A.ARTICULO=P.ARTICULO AND
A.COD_FABRICANTE=P.COD_FABRICANTE AND
A.PESO=P.PESO AND
A.CATEGORIA=P.CATEGORIA AND
A.COD_FABRICANTE=F.COD_FABRICANTE
AND F.nombre=nombrefabricante
GROUP BY F.COD_FABRICANTE;
dbms_output.put_line('numero de pedidos'||v_numpedidos);
dbms_output.put_line('facturacion'||v_facturacion);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('no existe datoos');
    WHEN OTHERS THEN 
    dbms_output.put_line('error general');
end EJER_8_2;

execute ejer_8_2('CALVO');

4.	/* Crea un procedimiento que al recibir el código de un colegio nos muestre la cantidad de profesores,
 por un lado, y también la cantidad de personal que trabaja en ese colegio. */

SELECT C.COD_CENTRO,COUNT(P.APELLIDOS) FROM CENTROS C,PROFESORES P WHERE
C.COD_CENTRO = P.COD_CENTRO GROUP BY C.COD_CENTRO;
CREATE OR REPLACE PROCEDURE EJERCICIO4 (COD NUMBER)
AS
V_NUM_PROFESORES NUMBER(2);
V_NUM_PERSONAL NUMBER(2);
BEGIN

SELECT COUNT(*) INTO V_NUM_PROFESORES FROM PROFESORES WHERE COD_CENTRO=COD;
SELECT COUNT(*) INTO V_NUM_PERSONAL FROM PERSONAL WHERE COD_CENTRO=COD
                                              AND FUNCION != 'PROFESOR';

DBMS_OUTPUT.PUT_LINE('El numero de profesores es: '|| V_NUM_PROFESORES);
DBMS_OUTPUT.PUT_LINE('El numero de empleados es: '|| V_NUM_PERSONAL);

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('ERROR GENERAL');
END EJERCICIO4;

5.	/* Crea una tabla con los mismos datos de fabricantes y con 
dos columnas m�s:
a.	Facturaci�n.
b.	N�mero_unidades.
Cada vez que se recibe un pedido (estos son los par�metros 
del procedure) 
el programa recalcula la facturaci�n y el n�mero de unidades PEDIDAS 
de ese fabricante, 
y actualiza en la tabla nueva esos datos. 
(Observaci�n: cuando crees la tabla ten presente 
que la necesitas con los datos.)
 */





CREATE TABLE FAB_FACT
AS SELECT * FROM FABRICANTES;

ALTER TABLE FAB_FACT
ADD FACTURACION NUMBER(8,2);

ALTER TABLE FAB_FACT
ADD NUMERO NUMBER(5);

ALTER TABLE FAB_FACT
ADD (FACTURACION NUMBER(8,2), 
     NUMERO NUMBER(5));


SELECT * FROM EMPLE;

CREATE OR REPLACE PROCEDURE EJERCICIO5
(N VARCHAR2, ART VARCHAR2, COD NUMBER, PES NUMBER, 
CAT VARCHAR2, UNI NUMBER)
AS
v_existe_tienda number(1);
v_existe_articulo number(1);
V_FACT NUMBER(6,2);
V_UNI NUMBER(4);
noexiste EXCEPTION;
/*declaramos la excepcion*/
BEGIN

select count(*) into v_existe_tienda from tiendas 
where nif = N;
select count(*) into v_existe_articulo from articulos 
 where articulo = ART and cod_fabricante = COD AND 
 peso = PES AND categoria=CAT;

IF (v_existe_tienda = 1 and v_existe_articulo = 1) then
INSERT INTO PEDIDOS 
VALUES (N, ART, COD, PES, CAT, SYSDATE, UNI);
else
dbms_output.put_line('El articulo o la tienda no existen');
raise noexiste;
/* lanzamos la excepcion */
end if;

SELECT SUM(UNIDADES_PEDIDAS*PRECIO_VENTA) INTO V_FACT
FROM ARTICULOS A, PEDIDOS P WHERE A.ARTICULO=P.ARTICULO 
AND A.COD_FABRICANTE=P.COD_FABRICANTE 
AND A.PESO=P.PESO AND A.CATEGORIA=P.CATEGORIA 
AND P.COD_FABRICANTE=COD;

SELECT SUM(UNIDADES_PEDIDAS) INTO V_UNI 
FROM PEDIDOS WHERE COD_FABRICANTE=COD;


/* Una vez calculada la facturaci�n y el n�mero de unidades
se procede a la actualizaci�n de la tabla resumen*/


UPDATE FAB_FACT
SET FACTURACION=V_FACT, NUMERO=V_UNI
WHERE COD_FABRICANTE=COD;

EXCEPTION
/* tratamiento de la excepcion */
WHEN NOEXISTE THEN
DBMS_OUTPUT.PUT_LINE('No existe alg�n registro padre');
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No hay datos');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Error');
END EJERCICIO5;

execute ejercicio5('5555-B','Macarrones', 20, 1, 'Primera', 10); 
execute ejercicio5('5555-B','Macarro', 20, 1, 'Primera', 10); 

6./*  Crea un procedimiento que realiza las siguientes acciones:
1.- inserta un art�culo nuevo y pasamos todos sus datos como par�metros. 
(se comprueba que el fabricante existe en la tabla FABRICANTES)
2.- insertar un pedido y una venta para cada una de las 
tiendas existentes (Unidades pedidas 5, Unidades vendidas 5).  
3.- Mostrar� la suma de las unidades pedidas y la suma de las 
unidades vendidas.
Observaciones: 
PK Art�culos: Art�culo, Cod_fabricante, Peso, Categor�a.
Gestiona excepciones: S�lo las suficientes y necesarias. */


CREATE OR REPLACE PROCEDURE EJERCICIO6 
(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2,
PV NUMBER,PC NUMBER,EXIS NUMBER)
AS
SUM_UNI_VEN NUMBER(3);
SUM_UNI_PED NUMBER(3);
v_existe number(1);
BEGIN

select count(*) into v_existe from fabricantes 
where cod_fabricante=cod;

if (v_existe=1) then
INSERT INTO ARTICULOS VALUES (ART, COD, PES, CAT, PV, PC, EXIS);

 INSERT INTO PEDIDOS 
 SELECT NIF, ART, COD, PES, CAT, SYSDATE, 5 FROM TIENDAS; 
 
 INSERT INTO VENTAS 
 SELECT NIF, ART, COD, PES, CAT, SYSDATE, 5 FROM TIENDAS;
 
 SELECT SUM(UNIDADES_PEDIDAS) INTO SUM_UNI_PED FROM PEDIDOS 
	WHERE ARTICULO=ART AND COD_FABRICANTE=COD AND CATEGORIA=CAT 
	AND PESO=PES;
 SELECT SUM(UNIDADES_VENDIDAS) INTO SUM_UNI_VEN FROM VENTAS 
	WHERE ARTICULO=ART AND COD_FABRICANTE=COD AND 
	CATEGORIA=CAT AND PESO=PES;

 DBMS_OUTPUT.PUT_LINE('Suma de unidades pedidas: '||SUM_UNI_PED);
 DBMS_OUTPUT.PUT_LINE('Suma de unidades vendidas: '||SUM_UNI_VEN);

else
dbms_output.put_line('El fabricante no existe');
end if;

EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('ERROR GENERAL');
END EJERCICIO6;

CREATE OR REPLACE PROCEDURE EJER_REF_8_13(P_fechai date, 
p_fechaf date, p_provincia varchar2)
AS
v_nombre tiendas.nombre%type;
v_num number(6);
BEGIN
SELECT NOMBRE, COUNT(*) into v_nombre, v_num
FROM TIENDAS T, VENTAS V
WHERE T.NIF = V.NIF
AND FECHA_VENTA BETWEEN P_FECHAI AND P_FECHAF 
AND PROVINCIA = P_PROVINCIA
GROUP BY NOMBRE
  HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM TIENDAS T, VENTAS V
  WHERE T.NIF = V.NIF
  AND FECHA_VENTA BETWEEN P_FECHAI AND P_FECHAF 
  AND PROVINCIA = P_PROVINCIA
  GROUP BY NOMBRE);
dbms_output.put_line('La tienda: '||v_nombre||' ha realizado '||v_num||' ventas');
exception
when too_many_rows then
 dbms_output.put_line('Demasiados datos');
when no_data_found then
 dbms_output.put_line('No hay datos');
when others then
 dbms_output.put_line('error');
END EJER_REF_8_13;

/* 7.	Crea un procedimiento que recibe los datos de un empleado (EMP_NO, APELLIDO, OFICIO, DIR, FECHA_ALT, COMISION, DEPT_NO) La comisión por defecto será 0.
(Recuerda que la asignación de valores a los parámetros es posicional en la ejecución del procedimiento). EL SALARIO estará en función del departamento en
el que se inserte al empleado, siendo este salario el salario medio de su departamento aumentado en un 3% y sin decimales.
Observaciones:
Controla que el empleado se inserta en un departamento existente y que el salario y la comisión son positivos.
Gestiona las excepciones necesarias y suficientes. */


/* 8.	Crea un procedimiento que a partir del nombre de un banco muestra los siguientes datos:
a.	Número de sucursales que tiene.
b.	Número de cuentas que tiene (en total, no agrupadas por sucursal)
c.	Suma de saldo_debe y de saldo_haber de todas sus cuentas. */

/* 9.	Crea un procedimiento que recibe los datos de una cuenta nueva (en una sucursal concreta, con unos saldos concretos)
y después se realiza una llamada al procedimiento anterior para ver los datos generales del banco donde se ha insertado esa cuenta nueva. */


/* 10.	Crea un procedimiento que a partir del nombre de un banco elimina ese banco y todo lo relativo a él. */







SELECT * FROM PROFESORES;


TEMA 9 EJERCICIOS REPASO
1.	/* Crea un procedimiento que recibe los datos de un profesor:

a.	Comprueba que el centro existe.
b.	Comprueba que su clave no se repite.
c.	Si los datos son correctos  el registro se inserta.
d.	Gestiona posibles excepciones. */

CREATE OR REPLACE PROCEDURE EJERCICIO_9_1 
(COD NUMBER, DN NUMBER, APE VARCHAR2, ESP VARCHAR2)
AS
NUM NUMBER(2);
CLAVE NUMBER(2);
BEGIN
SELECT COUNT(*) INTO NUM FROM CENTROS WHERE COD_CENTRO = COD;
SELECT COUNT(*) INTO CLAVE FROM PROFESORES WHERE DNI= DN;
 IF (NUM=1 AND CLAVE=0) THEN
 INSERT INTO PROFESORES VALUES (COD, DN, APE, ESP);
 ELSE
 DBMS_OUTPUT.PUT_LINE('EL CENTRO NO EXISTE O EL  DNI SE REPITE');
 END IF;
EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('ERROR GENERAL');
END EJERCICIO_9_1;

-------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EJERCICIO_9_1 
(COD NUMBER, DN NUMBER, APE VARCHAR2, ESP VARCHAR2)
AS
NUM NUMBER(2);
CLAVE NUMBER(2);
BEGIN
SELECT COUNT(*) INTO NUM FROM CENTROS WHERE COD_CENTRO = COD;
 IF (NUM=1) THEN
 SELECT COUNT(*) INTO CLAVE FROM PROFESORES WHERE DNI= DN;
  if (clave=0) then
    INSERT INTO PROFESORES VALUES (COD, DN, APE, ESP);
     ELSE
    DBMS_OUTPUT.PUT_LINE('EL DNI SE REPITE');
  END IF;
 else
DBMS_OUTPUT.PUT_LINE('EL CENTRO NO EXISTE');
end if; 
EXCEPTION.
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('ERROR GENERAL');
END EJERCICIO_9_1;

---------------------------------------------------------------------------------------------------------------------------- 

SELECT * FROM EMPLE;



2.	/* Crea un procedimiento que recibe los datos de un empleado y realiza las siguientes acciones:
a.	Comprueba que existe el dir y el departamento del empleado.
b.	Comprueba que el salario es positivo.
c.	Si todos los datos son correctos  inserta el empleado.
d.	Muestra por pantalla el gasto total en salarios del departamento del nuevo empleado.
e.	Gestiona posibles excepciones. */

CREATE OR REPLACE PROCEDURE EJERCICIO_9_2(EMP NUMBER, APE VARCHAR2, 
OFI VARCHAR2, D NUMBER, FECHA DATE, SAL NUMBER, COM NUMBER, DEP NUMBER)
AS
V_DIR NUMBER(2);
V_DEPT_NO NUMBER(2);
V_SUM_SAL NUMBER(7);
BEGIN
IF (SAL > 0) THEN
SELECT COUNT(*) INTO V_DIR FROM EMPLE WHERE EMP_NO=D;
SELECT COUNT(*) INTO V_DEPT_NO FROM DEPART WHERE DEPT_NO=DEP;

 IF (V_DIR=1 AND V_DEPT_NO=1) THEN
  INSERT INTO EMPLE VALUES (EMP, APE, OFI, D, FECHA, SAL, COM, DEP);
  DBMS_OUTPUT.PUT_LINE('EMPLEADO INSERTADO');
  SELECT SUM(SALARIO) INTO V_SUM_SAL FROM EMPLE WHERE DEPT_NO=DEP GROUP BY DEPT_NO;
    DBMS_OUTPUT.PUT_LINE('EL GASTO EN SALARIO DEL DEPARTAMENTO '||DEP||' ES '||V_SUM_SAL);
 ELSE
  DBMS_OUTPUT.PUT_LINE('EL JEFE O EL DEPARTAMENTO NO EXISTEN');
 END IF;

ELSE
 DBMS_OUTPUT.PUT_LINE('EL SALARIO ES NEGATIVO O CERO');
END IF;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('ERROR');
END EJERCICIO_9_2;

BEGIN EJERCICIO_9_2(11,'MARTINEZ','VENDEDOR',7369, SYSDATE, 2000,0,10); END;
-------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE EJERCICIO_9_2(EMP NUMBER, APE VARCHAR2, 
OFI VARCHAR2, D NUMBER, FECHA DATE, SAL NUMBER, COM NUMBER, DEP NUMBER)
AS
V_DIR NUMBER(2);
V_DEPT_NO NUMBER(2);
V_SUM_SAL NUMBER(7);
BEGIN
SELECT COUNT(*) INTO V_DIR FROM EMPLE WHERE EMP_NO=D;
SELECT COUNT(*) INTO V_DEPT_NO FROM DEPART WHERE DEPT_NO=DEP;

IF (SAL > 0 and V_DIR=1 AND V_DEPT_NO=1) THEN

  INSERT INTO EMPLE VALUES (EMP, APE, OFI, D, FECHA, SAL, COM, DEP);
  DBMS_OUTPUT.PUT_LINE('EMPLEADO INSERTADO');
  SELECT SUM(SALARIO) INTO V_SUM_SAL FROM EMPLE WHERE DEPT_NO=DEP GROUP BY DEPT_NO;
  DBMS_OUTPUT.PUT_LINE('EL GASTO EN SALARIO DEL DEPARTAMENTO '||DEP||' ES '||V_SUM_SAL);
  
ELSE
  DBMS_OUTPUT.PUT_LINE('EL JEFE O EL DEPARTAMENTO NO EXISTEN o el  salario es negativo');
END IF;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('ERROR');
END EJERCICIO_9_2;


3./* 	Crea un procedimiento que recibe los datos de un pedido y realiza las siguientes acciones:
a.	Comprueba que el artículo existe en la tabla padre.
b.	Comprueba que la tienda existe.
c.	Si las unidades del pedido son superiores a las existencias, sólo asigna al pedido el 20% de las existencias.
d.	La fecha de pedido es la actual.
e.	Una vez insertado el pedido resta las unidades pedidas a las existencias del artículo. */
CREATE OR REPLACE PROCEDURE EJERCI_9_3(NIFS NUMBER ,ART VARCHAR2,CDFAB NUMBER,PPESO NUMBER,PCATEGORIA VARCHAR2,UNIDADES NUMBER,FECHAPE DATE  DEFAULT SYSDATE)
AS
v_articulo NUMBER(3);
V_TIENDA NUMBER(3);
V_EXISTENCIAS NUMBER(3);
V_UNIDADES NUMBER(4);
BEGIN 
SELECT COUNT(*) INTO V_ART FROM ARTICULOS WHERE ARTICULO=ART AND COD_FABRICANTE=CDFAB AND PESO=PPESO AND CATEGORIA=PCCATEGORIA;
SELECT COUNT(*) INTO V_TIENDA FROM TIENDAS WHERE NIFS=NIF;

IF (V_TIENDA >0 AND v_articulo >0) THEN
SELECT EXISTENCIAS INTO V_EXISTENCIAS FROM ARTICULOS WHERE ARTICULO=ART AND COD_FABRICANTE=CDFAB AND PESO=PPESO AND CATEGORIA=PCATEGORIA;
  IF(UNIDADES>V_EXISTENCIAS) THEN
  V_UNIDADES=:TRUNC(V_EXISTENCIAS*0.2);
  ELSE
  V_UNIDADES=:V_EXISTENCIAS;
  END IF;
INSERT INTO PEDIDOS VALUES (NIFS,ART,CDFAB,PPESO,PCATEGORIA,FECHAPE,V_UNIDADES);


ELSE DBMS_OUTPUT.PUT_LINE('el nif o articulo no existe');
END IF;


























CREATE OR REPLACE PROCEDURE EJERCICIO_9_3(N VARCHAR2, ART VARCHAR2, COD NUMBER, 
PES NUMBER, CAT VARCHAR2,UNID NUMBER, FECHA DATE DEFAULT SYSDATE)
AS
V_ART NUMBER(2);
V_NIF NUMBER(2);
V_EXIST NUMBER(4);
V_UNI NUMBER(3);
BEGIN
SELECT COUNT(*) INTO V_ART FROM ARTICULOS 
  WHERE ARTICULO=ART AND PESO=PES AND COD_FABRICANTE = COD AND CATEGORIA=CAT;
SELECT COUNT(*) INTO V_NIF FROM TIENDAS WHERE NIF=N;

IF (V_ART=1 AND V_NIF=1) THEN
 SELECT EXISTENCIAS INTO V_EXIST FROM ARTICULOS 
  ELSE
    V_UNI:=UNID;
  END IF;  
 INSERT INTO PEDIDOS VALUES (N, ART, COD, PES, CAT, FECHA, V_UNI);
 UPDATE ARTICULOS SET EXISTENCIAS = EXISTENCIAS-V_UNI 
 WHERE ARTICULO=ART AND PESO=PES AND COD_FABRICANTE = COD AND CATEGORIA=CAT;
ELSE
 DBMS_OUTPUT.PUT_LINE('EL NIF O EL ARTICULO NO EXISTEN');
END IF;
EXCEPTION
WHEN OTHERS THEN 
 DBMS_OUTPUT.PUT_LINE('ERROR');
END EJERCICIO_9_3;
    
 
BEGIN EJERCICIO_9_3('1111-A', 'Macarrones', 20, 1, 'Primera', 1000, sysdate); END;


4./* 	Crea un procedimiento que al recibir los datos de una venta realiza las siguientes acciones:
a.	Muestra la facturación de la tienda (en ventas) antes de insertarse la venta.
b.	Se comprueba que todos los datos de la venta son correctos, como en el ejercicio 3.
c.	Se inserta la venta.
d.	 Vuelve a mostrar la facturación de la tienda una vez insertada la venta.
e.	Gestiona las posibles excepciones. */

CREATE OR REPLACE PROCEDURE EJERCICIO_9_4(N VARCHAR2, ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2, UNID NUMBER)
AS
V_ART NUMBER(2);
V_NIF NUMBER(2);
V_EXIST NUMBER(4);
V_UNI NUMBER(3);
V_FACT NUMBER(8,2);
BEGIN
SELECT COUNT(*) INTO V_ART FROM ARTICULOS 
 WHERE ARTICULO=ART AND PESO=PES AND COD_FABRICANTE = COD AND CATEGORIA=CAT;
SELECT COUNT(*) INTO V_NIF FROM TIENDAS WHERE NIF=N;

IF (V_ART=1 AND V_NIF=1) THEN

SELECT SUM(PRECIO_VENTA*UNIDADES_VENDIDAS) INTO V_FACT 
 FROM ARTICULOS A, VENTAS V 
 WHERE A.ARTICULO=V.ARTICULO AND A.COD_FABRICANTE=V.COD_FABRICANTE 
 AND A.PESO=V.PESO AND A.CATEGORIA=V.CATEGORIA AND NIF=N;

 DBMS_OUTPUT.PUT_LINE(V_FACT);

 
SELECT EXISTENCIAS INTO V_EXIST FROM ARTICULOS 
 WHERE ARTICULO=ART AND PESO=PES AND COD_FABRICANTE = COD AND CATEGORIA=CAT;
  IF (V_EXIST < UNID) THEN
    V_UNI:=TRUNC(V_EXIST*0.2);
  ELSE
    V_UNI:=UNID;
  END IF;
  
INSERT INTO VENTAS VALUES (N, ART, COD, PES, CAT, SYSDATE, V_UNI);
 
 UPDATE ARTICULOS SET EXISTENCIAS = EXISTENCIAS-V_UNI 
 WHERE ARTICULO=ART AND PESO=PES AND COD_FABRICANTE = COD AND CATEGORIA=CAT;

 SELECT SUM(PRECIO_VENTA*UNIDADES_VENDIDAS) INTO V_FACT 
 FROM ARTICULOS A, VENTAS V 
WHERE A.ARTICULO=V.ARTICULO AND A.COD_FABRICANTE=V.COD_FABRICANTE 
AND A.PESO=V.PESO AND A.CATEGORIA=V.CATEGORIA AND NIF=N;
DBMS_OUTPUT.PUT_LINE(V_FACT);
ELSE
 DBMS_OUTPUT.PUT_LINE('EL NIF O EL ARTICULO NO EXISTEN');
END IF;
EXCEPTION
WHEN OTHERS THEN 
 DBMS_OUTPUT.PUT_LINE('ERROR');
END EJERCICIO_9_4;

BEGIN EJERCICIO_9_4('1111-A', 'Macarrones', 20, 1, 'Primera', 23); end;




5.	/* Crea un procedimiento que recibe 2 fechas,
 y muestra la facturación de la venta y los pedidos de todas las tiendas entre esas dos fechas. */

CREATE OR REPLACE PROCEDURE FACT(F1 DATE, F2 DATE)
AS
FACT_PEDIDOS NUMBER(8,2);
FACT_VENTAS NUMBER(8,2);
BEGIN
SELECT nvl(SUM(UNIDADES_PEDIDAS*PRECIO_VENTA),0) INTO FACT_PEDIDOS 
FROM ARTICULOS A, PEDIDOS P 
WHERE A.ARTICULO=P.ARTICULO AND A.COD_FABRICANTE=P.COD_FABRICANTE 
AND A.PESO=P.PESO 
AND A.CATEGORIA=P.CATEGORIA AND FECHA_PEDIDO BETWEEN F1 AND F2;  

SELECT nvl(SUM(UNIDADES_VENDIDAS*PRECIO_VENTA),0) INTO FACT_VENTAS 
FROM ARTICULOS A, VENTAS V 
WHERE A.ARTICULO=V.ARTICULO AND A.COD_FABRICANTE=V.COD_FABRICANTE 
AND A.PESO=V.PESO 
AND A.CATEGORIA=V.CATEGORIA AND FECHA_venta BETWEEN F1 AND F2;

DBMS_OUTPUT.PUT_LINE('Facturacion de pedidos: '||FACT_PEDIDOS);
DBMS_OUTPUT.PUT_LINE('Facturacion de ventas: '||FACT_VENTAS);

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('ERROR');
END FACT;

BEGIN DBMS_OUTPUT.PUT_LINE(FACT('01/01/2005','31/12/2006')); END; 


6.	/* Crea una función que recibe como parámetro el número de departamento y nos devuelve el número de empleados
 que existen en ese departamento. Después crea un procedimiento que realiza una llamada a esa función. */

CREATE OR REPLACE FUNCTION EJER_6(N_DEPT NUMBER)
RETURN NUMBER
AS
V_NUM NUMBER(2);
BEGIN
SELECT COUNT(*) INTO V_NUM FROM EMPLE WHERE DEPT_NO=N_DEPT;
RETURN V_NUM;
END EJER_6;

Select * from FABRICANTES;
------------------procedimiento que llama a la funci�n------------------
CREATE OR REPLACE PROCEDURE EJER_6_PROC(N_DEPT NUMBER)
AS
V NUMBER(2);
BEGIN
V := EJER_6(N_DEPT); --llamada a la funci�n.
DBMS_OUTPUT.PUT_LINE('El numero de empleados de '||N_DEPT||' es '||V);
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('ERROR');
END EJER_6_PROC;

BEGIN
EJER_6_PROC(10);
END;
------------------llamada a la funci�n desde bloque anonimo--------------

BEGIN
DBMS_OUTPUT.PUT_LINE(EJER_6(10));
END;

7.	/* Escribe una función que toma la PK de un artículo y nos devuelve la suma de unidades pedidas de ese artículo. */

CREATE OR REPLACE FUNCTION EJER_7
(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2)
RETURN NUMBER
AS
V_UNI_PEDIDAS NUMBER(4);
BEGIN
SELECT SUM(UNIDADES_PEDIDAS) INTO V_UNI_PEDIDAS FROM PEDIDOS 
WHERE ARTICULO=ART AND COD_FABRICANTE=COD AND PESO=PES AND CATEGORIA=CAT;
RETURN V_UNI_PEDIDAS;

EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('SIN DATOS');
END EJER_7;

BEGIN
DBMS_OUTPUT.PUT_LINE(EJER_7('Macarrones',20,1,'Primera'));
END;

8./* 	Crea un procedimiento que actualiza las existencias de un artículo que recibe como parámetro, restando a 
las existencias la suma de unidades pedidas de ese artículo. Utiliza la función del ejercicio anterior. */

CREATE OR REPLACE PROCEDURE EJER_8(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2)
AS
V_UNI_PED NUMBER(4);
BEGIN

V_UNI_PED:=EJER_7(ART, COD, PES, CAT);

UPDATE ARTICULOS SET EXISTENCIAS=EXISTENCIAS-V_UNI_PED
WHERE ARTICULO=ART AND COD_FABRICANTE=COD AND PESO=PES AND CATEGORIA=CAT;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('NO HAY DATOS');

END EJER_8;


9.	/* Crea un programa que recibe los datos de un artículo. Este programa tiene las siguientes funcionalidades:
a.	Tiene un procedimiento local almacenado que recibe los datos del artículo y devuelve por pantalla su facturación.
b.	Tiene un procedimiento almacenado local que calcula el número de pedidos de ese artículo y lo muestra por pantalla.
c.	Finalmente el procedimiento principal realiza una llamada a cada uno de los procedimientos locales. */

CREATE OR REPLACE PROCEDURE EJER_9 
(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2)
AS
PROCEDURE FACT(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2)
 AS V_FACT NUMBER(7,2);
 BEGIN
  SELECT SUM(UNIDADES_PEDIDAS*PRECIO_VENTA) INTO V_FACT FROM ARTICULOS A, PEDIDOS P 
  WHERE A.ARTICULO=P.ARTICULO AND A.COD_FABRICANTE=P.COD_FABRICANTE
  AND A.PESO=P.PESO AND A.CATEGORIA=P.CATEGORIA 
  and A.ARTICULO=ART AND A.COD_FABRICANTE=COD AND  A.PESO=PES AND A.CATEGORIA=CAT;
  DBMS_OUTPUT.PUT_LINE(V_FACT);
END FACT;
PROCEDURE NUM_PED(ART VARCHAR2, COD NUMBER, PES NUMBER, CAT VARCHAR2)
 AS V_NUM_PED NUMBER(2);
 BEGIN
  SELECT COUNT(*) INTO V_NUM_PED FROM PEDIDOS WHERE ARTICULO=ART
  AND COD_FABRICANTE=COD AND PESO=PES AND CATEGORIA=CAT;
  DBMS_OUTPUT.PUT_LINE(V_NUM_PED);
 END NUM_PED;
BEGIN
FACT(ART, COD, PES, CAT);
NUM_PED(ART, COD, PES, CAT);
END EJER_9;

BEGIN EJER_9('Macarrones', 20, 1, 'Primera'); END;

10./* 	Crea un procedimiento que recibe el numero de un departamento y tiene los siguientes especificaciones:
a.	Función local que con el departamento nos devuelve el número de empleados.
b.	Función local que con el departamento nos devuelve el gasto en salario.
c.	El procedimiento realiza llamadas a las funciones locales y muestra el resultado por pantalla. */

CREATE OR REPLACE PROCEDURE EJER_10(DEPT NUMBER)
AS
V_SUM_SALARIO NUMBER(7,2);
V_NUM_EMPLE NUMBER(2);

FUNCTION NUM_EMPLE (DEPT NUMBER)
RETURN NUMBER
AS
V_NUM NUMBER(2);
BEGIN
 SELECT COUNT(*) INTO V_NUM FROM EMPLE WHERE DEPT_NO=DEPT;
 RETURN V_NUM;
END NUM_EMPLE;

FUNCTION SUM_SALARIO (DEPT NUMBER)
RETURN NUMBER
AS
 V_SALARIO NUMBER(7,2);
BEGIN
 SELECT SUM(SALARIO) INTO V_SALARIO FROM EMPLE WHERE DEPT_NO=DEPT;
 RETURN V_SALARIO;
END SUM_SALARIO;

BEGIN
 V_SUM_SALARIO:=SUM_SALARIO(DEPT);
 V_NUM_EMPLE:= NUM_EMPLE(DEPT);
 DBMS_OUTPUT.PUT_LINE(V_SUM_SALARIO);
 DBMS_OUTPUT.PUT_LINE(V_NUM_EMPLE);
END EJER_10;

/* EJERCICIO 10bis: Crea una funci�n que devuelve la facturaci�n de un fabricante que 
se pasa como par�metro. */

CREATE OR REPLACE FUNCTION FACT_FABRICANTE (P_COD_FABRICANTE NUMBER)
RETURN NUMBER
AS

V_FACT NUMBER(8,2);

BEGIN

SELECT ROUND(SUM(PRECIO_VENTA*UNIDADES_VENDIDAS), 2) INTO V_FACT 
FROM ARTICULOS A, VENTAS V
WHERE A.ARTICULO=V.ARTICULO AND A.COD_FABRICANTE=V.COD_FABRICANTE AND A.PESO=V.PESO
AND A.CATEGORIA=V.CATEGORIA AND A.COD_FABRICANTE=P_COD_FABRICANTE;

RETURN V_FACT;

EXCEPTION
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('ERROR GENERAL');
END FACT_FABRICANTE;

BEGIN
DBMS_OUTPUT.PUT_LINE(FACT_FABRICANTE(15));
END;
/

Crea un procedimiento que llama a la funci�n anterior. 
El argumento del procedimiento es el nombre del fabricante y no su num.

CREATE OR REPLACE PROCEDURE FACT_FAB(P_NOMBRE VARCHAR2)
AS
V_COD_FACT FABRICANTES.COD_FABRICANTE%TYPE;
V_FACTURACION NUMBER(8,2);
BEGIN

SELECT COD_FABRICANTE INTO V_COD_FACT FROM FABRICANTES 
WHERE NOMBRE = P_NOMBRE;

V_FACTURACION := FACT_FABRICANTE(V_COD_FACT);
DBMS_OUTPUT.PUT_LINE(P_NOMBRE||' factura '||v_facturacion);

EXCEPTION 
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('no hay registros');
WHEN TOO_MANY_ROWS THEN
DBMS_OUTPUT.PUT_LINE('demasiadas filas');
WHEN others THEN
DBMS_OUTPUT.PUT_LINE('demasiadas filas');
END FACT_FAB;

11.	/* Crea un procedimiento con los siguientes especificaciones:
a.	Recibe un nombre de centro y especialidad.
b.	Tiene un procedimiento local que nos indica cuantos profesores hay con esa especialidad y en ese centro.
c.	Tiene una función local que nos devuelve el número de profesores en total con esa especialidad.
d.	El procedimiento principal realiza llamadas a ambos programas locales.
 */
CREATE OR REPLACE PROCEDURE EJER_REF9_11(P_NOMBRE VARCHAR2, P_ESPECIALIDAD VARCHAR2)
AS
V NUMBER(3);

PROCEDURE CONTAR(P_NOMBRE VARCHAR2, P_ESPECIALIDAD VARCHAR2)
AS
V_TOTAL NUMBER(3);
BEGIN
SELECT COUNT(*) INTO V_TOTAL FROM PROFESORES P, CENTROS C
WHERE P.COD_CENTRO=C.COD_CENTRO AND NOMBRE=P_NOMBRE AND ESPECIALIDAD=P_ESPECIALIDAD;
DBMS_OUTPUT.PUT_LINE(P_NOMBRE||' '||P_ESPECIALIDAD||' '||V_TOTAL);
END CONTAR;

FUNCTION CONTAR_POR_ESPECIALIDAD(P_ESPECIALIDAD VARCHAR2)
RETURN NUMBER
AS
V_TOTAL NUMBER(3);
BEGIN
SELECT COUNT(*) INTO V_TOTAL FROM PROFESORES WHERE ESPECIALIDAD=P_ESPECIALIDAD;
RETURN V_TOTAL;
END CONTAR_POR_ESPECIALIDAD;

BEGIN
CONTAR(P_NOMBRE, P_ESPECIALIDAD);
V:=CONTAR_POR_ESPECIALIDAD(P_ESPECIALIDAD);
DBMS_OUTPUT.PUT_LINE(V);
END EJER_REF9_11;




12./* 	Crea un procedimiento que recibe los datos de un pedido con las siguientes identificaciones:
a.	Crea una función local que devuelve las Existencias de ese artículo.
b.	Si existencias es menor que unidades_pedidas, las unidades pedidas serán ½ de las existencias (Parámetro de E/S).
c.	Inserta el pedido y actualiza las unidades pedidas.
d.	Se vuelve a llamar a la función para que muestre las existencias actuales. */


13.	/* Crea un procedimiento que recibe todos los datos de un pedido (Simétrico con ventas) que pedirá:
a.	Si en la llamada los recibe todos o no, hará lo siguiente:
i.	Si no recibe todos, inserta un artículo.
ii.	Si recibe todos pregunta al usuario si quiere insertar un pedido o una venta.
iii.	Una vez insertado, actualiza el stock del artículo. (Sólo si es pedido) y en la tabla T_FABRICANTES suma las unidades pedidas totales de los artículos de ese fabricante.
iv.	Si es una venta en la tabla T_VENTAS incrementa las unidades vendidas de esa tienda.
T_FABRICANTES (cod_fabricante, nombre, cantidad)
T_VENTAS (Nif, Nombre, Cantidad)
         */

CREATE OR REPLACE PROCEDURE EJER_REF_9_13(ART VARCHAR2, COD NUMBER, PES NUMBER, 
										  CAT VARCHAR2, TIPO VARCHAR2,
                                          N VARCHAR2 DEFAULT 0, UNI NUMBER DEFAULT 0)
AS
BEGIN
IF (N = 0) THEN
 INSERT INTO ARTICULOS (ARTICULO, COD_FABRICANTE, PESO, CATEGORIA)
 VALUES
 (ART, COD, PES, CAT);
ELSE
  IF (TIPO = 'V') THEN
   INSERT INTO VENTAS VALUES (N, ART, COD, PES, CAT, SYSDATE, UNI);

   UPDATE T_TIENDAS
   SET CANTIDAD = CANTIDAD + UNI
   WHERE NIF = N;
  
  ELSE
   INSERT INTO PEDIDOS VALUES (N, ART, COD, PES, CAT, SYSDATE, UNI);
   UPDATE ARTICULOS SET EXISTENCIAS = EXISTENCIAS + UNI
   WHERE ARTICULO=ART AND COD_FABRICANTE=COD AND PESO=PES AND CATEGORIA=CAT;
   UPDATE T_FABRICANTES
   SET CANTIDAD = CANTIDAD + UNI
   WHERE COD_FABRICANTE = COD;
  END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
 dbms_output.put_line('error');
END EJER_REF_9_13;





BEGIN
DBMS_OUTPUT.put_line('HOLA');
END;


/* 1- INTRODUCIMOS EN LA FUNCIÓN UN NOMBRE Y FECHA Y DEVUELVE EL Nº DE PEDIDOS DE ESE FABRICANTE EN ESE DÍA */
CREATE OR REPLACE FUNCTION EJER_FUNC1(P_NOMBRE VARCHAR2, p_FECHA date)
  return  NUMBER
  AS
  v_num_pedidos number(4);
  BEGIN 
SELECT COUNT(*) INTO v_num_pedidos FROM PEDIDOS
  WHERE COD_FABRICANTE=(SELECT COD_FABRICANTE FROM FABRICANTES WHERE COD_FABRICANTE=(SELECT COD_FABRICANTE FROM FABRICANTES WHERE NOMBRE = P_NOMBRE)) AND
  FECHA_PEDIDO=P_FECHA;
RETURN V_NUM_PEDIDOS;
  END EJER_FUNC1;
/* 2- DEVOLVER EL NOMBRE DE FABRICANTE CON EL RESULTADO DE LA FUNCIÓN ANTERIOR. */
CREATE OR REPLACE PROCEDURE EJER_PROC1(P_NOMBRE VARCHAR2, P_FECHA DATE)
    AS
    BEGIN
    DBMS_OUTPUT.PUT_LINE('la cantidad tiene'||EJER_FUNC1(p_nombre,p_fecha));
    END EJER_PROC1;



TEMA 10

CREATE OR REPLACE PROCEDURE VER_DEPART
AS
CURSOR C_dEPART IS SELECT * FROM DEPART;
BEGIN 
FOR V_REG IN C_DEPART LOOP
  DBMS_OUTPUT.PUT_LINE(' '||V_REG.DNOMBRE);
END LOOP;
END VER_DEPART;

EXECUTE VER_DEPART;

/*VER LOS EMPLADOS DE UN DEPARTAMENTO*/
CREATE OR REPLACE PROCEDURE VER_EMPLE(NUMDEPT NUMBER)
AS
CURSOR INFORMACION IS SELECT * FROM EMPLE WHERE DEPT_NO =NUMDEPT;
BEGIN 
FOR V_REG IN INFORMACION LOOP
  DBMS_OUTPUT.PUT_LINE(RPAD(V_REG.EMP_NO,10)||' '||RPAD(V_REG.APELLIDO,20)||RPAD(V_REG.OFICIO,10)||RPAD(NVL(V_REG.DIR,0),15)||RPAD(V_REG.FECHA_ALT,10)||RPAD(V_REG.SALARIO,10)||RPAD(V_REG.COMISION,10)||RPAD(V_REG.DEPT_NO,10));
END LOOP;
END VER_EMPLE;

EXECUTE   VER_EMPLE(10);

SELECT * FROM VENTAS;



-- PRACTICAS EXAMEN
-- TEMA 8

-- 1.	Crea un procedimiento que a través del parámetro DEPT_NO de un departamento muestre: el número de departamento, su nombre y su localidad, así como el número de empleados que trabajan en ese departamento. Gestiona excepciones.
Create OR REPLACE PROCEDURE repasotema8_1(p_dept_no NUMBER)
AS 
 V_NUM_DEPART NUMBER(4);
 V_NOMBRE VARCHAR2(20);
 V_LOCALIDAD VARCHAR2(15);
 V_NUM_EMPLE NUMBER(4);
BEGIN
SELECT D.DEPT_NO,DNOMBRE,LOC,COUNT(APELLIDO) INTO V_NUM_DEPART,V_NOMBRE,V_LOCALIDAD,V_NUM_EMPLE 
FROM DEPART D,EMPLE E WHERE E.DEPT_NO=D.DEPT_NO AND D.DEPT_NO=P_DEPT_NO GROUP BY D.DEPT_NO,DNOMBRE,LOC;
  DBMS_OUTPUT.PUT_LINE(V_NUM_DEPART||' '||V_NOMBRE||' '||V_LOCALIDAD||' '||V_NUM_EMPLE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE('No existe el departamento');
END repasotema8_1;

EXECUTE repasotema8_1(10);

SELECT D.DEPT_NO,DNOMBRE,LOC,COUNT(APELLIDO) FROM EMPLE E,DEPART D WHERE E.DEPT_NO=D.DEPT_NO AND D.DEPT_NO=10 GROUP BY D.DEPT_NO,DNOMBRE,LOC;

-- 2.	Pasando el Dept_no como parámetro calcula para cada oficio el número de empleados que tiene, puede salir 0. 
-- Observación: Dado que sólo tenemos cursores implícitos no podemos tener mas de una respuesta por cada consulta  necesitamos 
-- una consulta distinta para contar cada uno de los oficios. Gestiona también las excepciones.

CREATE OR REPLACE PROCEDURE repasotema8_2(p_dept_no NUMBER)
  AS
    V_EMPLEADO NUMBER(10);
    V_VENDEDOR NUMBER(10);
    V_DIRECTOR NUMBER(10);
    V_ANALISTA NUMBER(10);
    V_PRESIDENTE NUMBER(10);
  BEGIN
    SELECT COUNT(*) INTO V_EMPLEADO FROM EMPLE WHERE OFICIO='EMPLEADO' AND DEPT_NO=P_DEPT_NO;
    SELECT COUNT(*) INTO V_VENDEDOR FROM EMPLE WHERE OFICIO='VENDEDOR' AND DEPT_NO=P_DEPT_NO;
    SELECT COUNT(*) INTO V_DIRECTOR FROM EMPLE WHERE OFICIO='DIRECTOR' AND DEPT_NO=P_DEPT_NO;
    SELECT COUNT(*) INTO V_ANALISTA FROM EMPLE WHERE OFICIO='ANALISTA' AND DEPT_NO=P_DEPT_NO;
    SELECT COUNT(*) INTO V_PRESIDENTE FROM EMPLE WHERE OFICIO='PRESIDENTE' AND DEPT_NO=P_DEPT_NO;
    DBMS_OUTPUT.PUT_LINE(V_EMPLEADO||' '||V_VENDEDOR||' '||V_DIRECTOR||' '||V_ANALISTA||' '||V_PRESIDENTE);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No existe el departamento');
END repasotema8_2;

EXECUTE repasotema8_2(10);



SELECT * FROM EMPLE;





-- 3.	Crea un procedimiento que al recibir el nombre de un fabricante nos muestra la facturación de ese fabricante, tanto en nº de pedidos como en facturación, es decir: precio_venta*unidades_pedidas.Ç
CREATE OR REPLACE PROCEDURE REPASOTEMA8_3(p_fabricante VARCHAR2)
  AS
    V_FACTURACION NUMBER(10);
    V_NUM_PEDIDOS NUMBER(10);
  BEGIN
    SELECT COUNT(P.ARTICULO),SUM(PRECIO_VENTA*UNIDADES_PEDIDAS) INTO V_NUM_PEDIDOS,V_FACTURACION FROM ARTICULOS A,PEDIDOS P,FABRICANTES F WHERE A.ARTICULO=P.ARTICULO 
      AND A.COD_FABRICANTE=P.COD_FABRICANTE AND
      A.PESO=P.PESO 
      AND A.CATEGORIA=P.CATEGORIA AND
      A.COD_FABRICANTE=F.COD_FABRICANTE AND
      F.NOMBRE=P_FABRICANTE  
      GROUP BY P.COD_FABRICANTE;
    DBMS_OUTPUT.PUT_LINE(V_FACTURACION||' '||V_NUM_PEDIDOS);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No existe el fabricante');
END REPASOTEMA8_3;

EXECUTE REPASOTEMA8_3('CALVO');



SELECT COUNT(P.ARTICULO),SUM(PRECIO_VENTA*UNIDADES_PEDIDAS) FROM ARTICULOS A,PEDIDOS P,FABRICANTES F WHERE A.ARTICULO=P.ARTICULO 
AND A.COD_FABRICANTE=P.COD_FABRICANTE AND
A.PESO=P.PESO 
AND A.CATEGORIA=P.CATEGORIA AND
A.COD_FABRICANTE=F.COD_FABRICANTE AND
F.NOMBRE='CALVO' 
GROUP BY P.COD_FABRICANTE;


-- 4.	Crea un procedimiento que al recibir el código de un colegio nos muestre la cantidad de profesores, por un lado, y también la cantidad de personal que trabaja en ese colegio.
SELECT * FROM PROFESORES;
SELECT * FROM CENTROS;
SELECT * FROM PERSONAL;

SELECT COUNT(*) FROM PROFESORES WHERE COD_CENTRO=10;
SELECT COUNT(*) FROM PERSONAL WHERE COD_CENTRO=10;
CREATE OR REPLACE PROCEDURE REPASOTEMA8_4(p_cod_centro NUMBER)
  AS
    V_PROFESORES NUMBER(10);
    V_PERSONAL NUMBER(10);
  BEGIN
    SELECT COUNT(*) INTO V_PROFESORES FROM PROFESORES WHERE COD_CENTRO=P_COD_CENTRO;
    SELECT COUNT(*) INTO V_PERSONAL FROM PERSONAL WHERE COD_CENTRO=P_COD_CENTRO;
    DBMS_OUTPUT.PUT_LINE(V_PROFESORES||' '||V_PERSONAL);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No existe el centro');
END REPASOTEMA8_4;

EXECUTE REPASOTEMA8_4(10);

-- 5.	Crea 1 tabla con los mismos datos de fabricantes y con 2 columnas más:
-- a.	Facturación.
-- b.	Número_unidades.
-- Cada vez que se recibe un pedido (estos son los parámetros del procedure) 
-- el programa recalcula la facturación y el número de unidades de ese fabricante, y actualiza en la tabla nueva esos datos.
--  (Observación: cuando crees la tabla ten presente que la necesitas con los datos.)

CREATE TABLE FABRICANTES_2
AS SELECT * FROM FABRICANTES;

ALTER TABLE FABRICANTES_2 
ADD (FACTURACION NUMBER(8,2),NUMERO NUMBER(5));

CREATE OR REPLACE PROCEDURE REPASOTEMA8_5
(P_NIF VARCHAR2(10),
P_ARTICULO VARCHAR2(10),
P_COD_FABRICANTE NUMBER(10),
P_PESO NUMBER(10),
P_CATEGORIA VARCHAR2(10),
P_UNIDADES_PEDIDAS NUMBER(10))
  AS
    V_FACTURACION NUMBER(8,2);
    V_NUMERO NUMBER(5);
  BEGIN
    SELECT COUNT(P.ARTICULO),SUM(PRECIO_VENTA*UNIDADES_PEDIDAS) INTO V_NUMERO,V_FACTURACION FROM ARTICULOS A,PEDIDOS P,FABRICANTES F WHERE A.ARTICULO=P.ARTICULO 
      AND A.COD_FABRICANTE=P.COD_FABRICANTE AND
      A.PESO=P.PESO 
      AND A.CATEGORIA=P.CATEGORIA AND
      A.COD_FABRICANTE=F.COD_FABRICANTE AND
      F.NIF=P_NIF AND
      A.ARTICULO=P_ARTICULO AND
      A.COD_FABRICANTE=P_COD_FABRICANTE AND
      A.PESO=P_PESO AND
      A.CATEGORIA=P_CATEGORIA AND
      A.UNIDADES_PEDIDAS=P_UNIDADES_PEDIDAS;
    DBMS_OUTPUT.PUT_LINE(V_FACTURACION||' '||V_NUMERO);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No existe el fabricante');
END REPASOTEMA8_5;






SELECT * FROM PEDIDOS;
SELECT * FROM FABRICANTES_2;

  





: cuando crees la tabla ten presente 
que la necesitas con los datos.)
 */





CREATE TABLE FAB_FACT
AS SELECT * FROM FABRICANTES;

ALTER TABLE FAB_FACT
ADD FACTURACION NUMBER(8,2);

ALTER TABLE FAB_FACT
ADD NUMERO NUMBER(5);

ALTER TABLE FAB_FACT
ADD (FACTURACION NUMBER(8,2), 
     NUMERO NUMBER(5));


SELECT * FROM EMPLE;

CREATE OR REPLACE PROCEDURE EJERCICIO5
(N VARCHAR2, ART VARCHAR2, COD NUMBER, PES NUMBER, 
CAT VARCHAR2, UNI NUMBER)
AS
v_existe_tienda number(1);
v_existe_articulo number(1);
V_FACT NUMBER(6,2);
V_UNI NUMBER(4);
noexiste EXCEPTION;
/*declaramos la excepcion*/
BEGIN

select count(*) into v_existe_tienda from tiendas 
where nif = N;
select count(*) into v_existe_articulo from articulos 
 where articulo = ART and cod_fabricante = COD AND 
 peso = PES AND categoria=CAT;

IF (v_existe_tienda = 1 and v_existe_articulo = 1) then
INSERT INTO PEDIDOS 
VALUES (N, ART, COD, PES, CAT, SYSDATE, UNI);
else
dbms_output.put_line('El articulo o la tienda no existen');
raise noexiste;
/* lanzamos la excepcion */
end if;

SELECT SUM(UNIDADES_PEDIDAS*PRECIO_VENTA) INTO V_FACT
FROM ARTICULOS A, PEDIDOS P WHERE A.ARTICULO=P.ARTICULO 
AND A.COD_FABRICANTE=P.COD_FABRICANTE 
AND A.PESO=P.PESO AND A.CATEGORIA=P.CATEGORIA 
AND P.COD_FABRICANTE=COD;

SELECT SUM(UNIDADES_PEDIDAS) INTO V_UNI 
FROM PEDIDOS WHERE COD_FABRICANTE=COD;


/* Una vez calculada la facturaci�n y el n�mero de unidades
se procede a la actualizaci�n de la tabla resumen*/


UPDATE FAB_FACT
SET FACTURACION=V_FACT, NUMERO=V_UNI
WHERE COD_FABRICANTE=COD;

EXCEPTION
/* tratamiento de la excepcion */
WHEN NOEXISTE THEN
DBMS_OUTPUT.PUT_LINE('No existe alg�n registro padre');
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No hay datos');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Error');
END EJERCICIO5;

execute ejercicio5('5555-B','Macarrones', 20, 1, 'Primera', 10); 
execute ejercicio5('5555-B','Macarro', 20, 1, 'Primera', 10); 






6.	Crea un procedimiento que inserta un artículo nuevo y pasamos todos sus datos como parámetros. 
Después el procedimiento intenta insertar un pedido y una venta para cada una de las tiendas existentes (Unidades pedidas 5, Unidades vendidas 5). 
 Mostrará la suma de las unidades vendidas y la suma de las unidades vendidas.
Observaciones: 
PK Artículos: Artículo, Cod_fabricante, Peso, Categoría.
Gestiona excepciones: Sólo las suficientes y necesarias.

CREATE OR REPLACE PROCEDURE EJERCICIO6R
(P_ARTICULO VARCHAR2, CODE NUMBER, PES NUMBER, CATEG VARCHAR2)
AS
INSERT INTO PEDIDOS 

BEGIN


-- 7.	Crea un procedimiento que recibe los datos de un empleado (EMP_NO, APELLIDO, OFICIO, DIR, FECHA_ALT, COMISION, DEPT_NO) La comisión por defecto será 0. (Recuerda que la asignación de valores a los parámetros es posicional en la ejecución del procedimiento). EL SALARIO estará en función del departamento en el que se inserte al empleado, siendo este salario el salario medio de su departamento aumentado en un 3% y sin decimales.
-- Observaciones:
-- Controla que el empleado se inserta en un departamento existente y que el salario y la comisión son positivos.
-- Gestiona las excepciones necesarias y suficientes.

-- 8.	Crea un procedimiento que a partir del nombre de un banco muestra los siguientes datos:
-- a.	Número de sucursales que tiene.
-- b.	Número de cuentas que tiene (en total, no agrupadas por sucursal)
-- c.	Suma de saldo_debe y de saldo_haber de todas sus cuentas.

-- 9.	Crea un procedimiento que recibe los datos de una cuenta nueva (en una sucursal concreta, con unos saldos concretos) y después se realiza una llamada al procedimiento anterior para ver los datos generales del banco donde se ha insertado esa cuenta nueva.
-- 10.	Crea un procedimiento que a partir del nombre de un banco elimina ese banco y todo lo relativo a él.


TEMA 10 CURSORES

TEMA 11 TRIGGERS

CREATE OR REPLACE TRIGGER TRIGGER_EJERCICIO1 


INSERT INTO EMPLE_h(emp_no, apellido, oficio,salario,dept_no)--tabla donde se insertara
VALUES
(:old.emp_no, :old.apellido, :old.oficio, :old.salario, :old.dept_no);
END TRIGGER_EJERCICIO1;



--CREA UN DISIPADOR SOBRE LA TABLA ARTICULOS DE TAL MODO QUE CADA VEZ QUE SE BORRA UN ARTICULO SE BORRN SUS PEDIDOS Y VENTAS
CREATE OR REPLACE TRIGGER TRIGGER_EJERCICIO2
BEFORE DELETE
ON ARTICULOS FOR EACH ROW
BEGIN
DELETE FROM PEDIDOS WHERE ARTICULO=:old.ARTICULO AND COD_FABRICANTE=:old.COD_FABRICANTE AND PESO=:old.PESO AND CATEGORIA=:old.CATEGORIA;
DELETE FROM VENTAS WHERE ARTICULO=:old.ARTICULO AND COD_FABRICANTE=:old.COD_FABRICANTE AND PESO=:old.PESO AND CATEGORIA=:old.CATEGORIA;
END TRIGGER_EJERCICIO2;

SELECT * FROM PEDIDOS ;

DELETE FROM ARTICULOS WHERE ARTICULO='Macarrones' AND COD_FABRICANTE=20 AND PESO=1 AND CATEGORIA='Primera';

SELECT * FROM EMPLE;

DEL LIBRO
1 Escribe un disparador de base de datos que permita
auditar las operaciones de inserción o borrado de
datos que se realicen en la tabla EMPLE según las
siguientes especificaciones:

– Cuando se produzca cualquier manipulación, se insertará
una fila en dicha tabla que contendrá: fecha y
hora, número de empleado, apellido y la operación de
actualización INSERCIÓN o BORRADO.

CREATE TABLE AUDITAREMPLE1
AS
SELECT * FROM EMPLE;

SELECT TO_CHAR(SYSDATE,'HH:MM') FROM 

ALTER TABLE AUDITAREMPLE1 ADD FECHA VARCHAR(20);
ALTER TABLE AUDITAREMPLE1 ADD HORA VARCHAR(20);
ALTER TABLE AUDITAREMPLE1 ADD ACCION VARCHAR(20);

CREATE OR REPLACE TRIGGER TRIGGER1LIBRO
BEFORE INSERT OR DELETE ON EMPLE 
FOR EACH ROW
BEGIN
IF INSERTING THEN
INSERT INTO AUDITAREMPLE1 VALUES(:new.EMP_NO, :new.APELLIDO, :new.OFICIO,:new.DIR,:new.FECHA_ALT,:new.SALARIO, :new.DEPT_NO, TO_CHAR(SYSDATE,'DD/MM/YYYY'), TO_CHAR(SYSDATE,'HH:MM'), 'INSERT');
ELSif DELETING THEN
INSERT INTO AUDITAREMPLE1 VALUES(:old.EMP_NO, :old.APELLIDO, :old.OFICIO,:old.DIR,:old.FECHA_ALT,:old.SALARIO, :old.DEPT_NO, TO_CHAR(SYSDATE,'DD/MM/YYYY'), TO_CHAR(SYSDATE,'HH:MM'), 'DELETE');
END IF;
END TRIGGER_EJERCICIO1;


EJERCICIOS REFUERZO TEMA 11

7.	Crea 2 triggers que realizan las siguientes acciones: 
a.	Cuando insertamos registros en la tabla NUEVOS (es de alumnos) inserta ese mismo registro en la tabla ALUM.

TRIGGER_EJERCICIO1 L
CREATE OR REPLACE TRIGGER REFUERZOTEMA11A
BEFORE INSERT ON NUEVOS 
FOR EACH ROW
BEGIN
INSERT INTO ALUM VALUES( :new.NOMBRE, :new.EDAD, :new.LOCALIDAD);
END REFUERZOTEMA11A;

b.	Cuando eliminamos registros de la tabla ALUM  inserta ese registro en la tabla ANTIGUOS y elimina ese mismo registro de la tabla NUEVOS si existe allí todavía.

CREATE OR REPLACE TRIGGER REFUERZOTEMA11B
BEFORE DELETE ON ALUM 
FOR EACH ROW
BEGIN
DELETE FROM NUEVOS WHERE NOMBRE=:old.NOMBRE AND EDAD=:old.EDAD AND LOCALIDAD=:old.LOCALIDAD;
INSERT INTO ANTIGUOS VALUES( :old.NOMBRE, :old.EDAD, :old.LOCALIDAD);
END REFUERZOTEMA11B;
AB

CREATE OR REPLACE TRIGGER REFUERZOTEMA11AB
BEFORE DELETE OR INSERT ON ALUM 
FOR EACH ROW
BEGIN
IF INSERTING THEN
INSERT INTO NUEVOS VALUES( :new.NOMBRE, :new.EDAD, :new.LOCALIDAD);
ELSif DELETING THEN
DELETE FROM NUEVOS WHERE NOMBRE=:old.NOMBRE AND EDAD=:old.EDAD AND LOCALIDAD=:old.LOCALIDAD;
INSERT INTO ANTIGUOS VALUES( :old.NOMBRE, :old.EDAD, :old.LOCALIDAD);
END IF;
END REFUERZOTEMA11AB;

11.	Crea un trigger sobre la tabla PROFESORES  de tal modo que cuando se inserte, borre, o actualice un registro de Profesores  se haga lo mismo en la tabla PERSONAL. 
Es decir, si insertamos un profesor  se inserta en Personal (los datos que procedan),  si se borra  se elimina el registro de personal, 
y si se actualizan datos controla los cambios en la tabla ‘Personal’ sólo de los datos que tengan en común ambas tablas.

CREATE OR REPLACE TRIGGER REFUERZOTEMA11_7
BEFORE DELETE OR INSERT OR UPDATE ON PROFESORES
FOR EACH ROW
BEGIN
IF INSERTING THEN
  INSERT INTO PERSONAL(COD_CENTRO,DNI,APELIDOS) VALUES (:new.COD_CENTRO,:new.dni,:new.apellidos);
ELSIF DELETING THEN
  DELETE FROM PERSONAL WHERE DNI=:old.dni;
ELSIF UPDATING THEN
  UPDATE PERSONAL SET COD_CENTRO=:NEW.COD_CENTRO,DNI=:NEW.DNI,APELLIDOS=:NEW.APELLIDOS WHERE DNI=:OLD.DNI ;
END IF;
END REFUERZOTEMA11_7;


--CREACION DE PAQUETES
ejercicio 1

CREATE OR REPLACE PACKAGE GESTION_EMPLEADOS
AS
PROCEDURE INSERTAR_EMPLEADO (P_APELLIDO varchar2, P_OFICIO varchar2, P_SALARIO number, P_DEPT_NO number);
PROCEDURE BORRAR_EMPLEADO (P_EMP_NO NUMBER);
END GESTION_EMPLEADOS;


CREATE OR REPLACE PACKAGE BODY GESTION_EMPLEADOS
AS
/*CODIGO DE LOS PROCEDIMIENTOS*/
PROCEDURE INSERTAR_EMPLEADO (P_APELLIDO varchar2, P_OFICIO varchar2, P_SALARIO number, P_DEPT_NO number)
AS
V_EMP_NO NUMBER(3);
BEGIN

SELECT MAX(EMP_NO)+1 INTO V_EMP_NO FROM EMPLE;
INSERT INTO EMPLE (EMP_NO, APELLIDO, OFICIO, SALARIO, DEPT_NO)
VALUES (V_EMP_NO, P_APELLIDO, P_OFICIO, P_SALARIO, P_DEPT_NO);

END INSERTAR_EMPLEADO;

PROCEDURE BORRAR_EMPLEADO (P_EMP_NO NUMBER)
AS
BEGIN
DELETE FROM EMPLE WHERE EMP_NO = P_EMP_NO;
END BORRAR_EMPLEADO;

END GESTION_EMPLEADOS;




2/gestion de departamentos
--CREACION DE PROCEDURES
CREATE OR REPLACE PROCEDURE INSERTARDEPARTAMENTO(P_NOMBRE VARCHAR2,P_LOCALIDAD VARCHAR2)
AS V_ULTIMO_DEPARTAMENTO NUMBER;
BEGIN
SELECT MAX(DEPT_NO)+10 INTO V_ULTIMO_DEPARTAMENTO FROM DEPART;
INSERT INTO DEPART VALUES(V_ULTIMO_DEPARTAMENTO,P_NOMBRE,P_LOCALIDAD);
END INSERTARDEPARTAMENTO;

CREATE OR REPLACE PROCEDURE ELIMINARDEPARTAMENTO(P_DEPARTAMENTO NUMBER)
AS 
BEGIN
UPDATE EMPLE SET DEPT_NO=40 WHERE DEPT_NO=P_DEPARTAMENTO;
DELETE FROM DEPART WHERE DEPT_NO=P_DEPARTAMENTO;
END ELIMINARDEPARTAMENTO;


--CREACION DE PACKAGE
CREATE OR REPLACE PACKAGE GESTIONDEPARTAMENTOS 
AS
PROCEDURE INSERTARDEPARTAMENTO(P_NOMBRE VARCHAR2,P_LOCALIDAD VARCHAR2);
PROCEDURE ELIMINARDEPARTAMENTO(P_DEPARTAMENTO NUMBER);
END GESTIONDEPARTAMENTOS;

CREATE OR REPLACE PACKAGE BODY GESTIONDEPARTAMENTOS
AS
PROCEDURE INSERTARDEPARTAMENTO(P_NOMBRE VARCHAR2,P_LOCALIDAD VARCHAR2)
AS V_ULTIMO_DEPARTAMENTO NUMBER;
BEGIN
SELECT MAX(DEPT_NO)+10 INTO V_ULTIMO_DEPARTAMENTO FROM DEPART;
INSERT INTO DEPART VALUES(V_ULTIMO_DEPARTAMENTO,P_NOMBRE,P_LOCALIDAD);
END INSERTARDEPARTAMENTO;

PROCEDURE ELIMINARDEPARTAMENTO(P_DEPARTAMENTO NUMBER)
AS 
BEGIN
UPDATE EMPLE SET DEPT_NO=40 WHERE DEPT_NO=P_DEPARTAMENTO;
DELETE FROM DEPART WHERE DEPT_NO=P_DEPARTAMENTO;
END ELIMINARDEPARTAMENTO;
END GESTIONDEPARTAMENTOS;

--EJECUTAR PROCEDURE DENTRO DE UN PAQUETE 
execute GESTIONDEPARTAMENTOS.INSERTARDEPARTAMENTO('DEPARTAMENTO1','LOCALIDAD1');

--VER CONTENIDO DE UN PAQUETE
SELECT text FROM all_source WHERE name = 'GESTIONDEPARTAMENTOS' AND type='PACKAGE BODY';






