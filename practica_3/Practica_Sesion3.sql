DECLARE
	v_GastoTotal NUMBER;
	v_ClienteID NUMBER := 0;

BEGIN
	LOOP
	v_ClienteID := V_ClienteID + 1;
	SELECT SUM(Total) INTO v_GastoTotal
	FROM Pedidos
	WHERE ClienteID = v_ClienteID;

	DBMS_OUTPUT.PUT_LINE('Gasto del cliente: ' || v_ClienteID);

	IF v_GastoTotal >= 1500 THEN
	DBMS_OUTPUT.PUT_LINE('Gasto mayor: ' || v_GastoTotal);
	ELSIF v_GastoTotal >= 500 THEN
	DBMS_OUTPUT.PUT_LINE('Gasto mediano: ' || v_GastoTotal);
	ELSE
	DBMS_OUTPUT.PUT_LINE('Gasto bajo: ' || v_GastoTotal);
	END IF;	
				
    	EXIT WHEN v_ClienteID >= 2;
	END LOOP;
     	DBMS_OUTPUT.PUT_LINE('Procesamiento completado.');
END;

	

	