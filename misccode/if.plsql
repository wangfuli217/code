-- Avoid clumsy IF statements such as:

IF new_balance < minimum_balance THEN
  overdrawn := TRUE;
ELSE
  overdrawn := FALSE;
END IF;

-- Instead, assign the value of the BOOLEAN expression directly to a BOOLEAN variable:

overdrawn := new_balance < minimum_balance;


---

IF <<some condition>>
THEN
  <<do something>>
ELSIF <<another condition>>
THEN
  <<do something else>>
ELSE
  <<do a third thing>>
END IF;
