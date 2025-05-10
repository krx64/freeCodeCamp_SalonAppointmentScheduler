# psql --username=freecodecamp --dbname=postgres

# CREATE DATABASE salon;

# \c salon;

# CREATE TABLE customers(customer_id SERIAL PRIMARY KEY, phone VARCHAR(20) UNIQUE, name VARCHAR(30));
# CREATE TABLE services(service_id SERIAL PRIMARY KEY, name VARCHAR(30));
# CREATE TABLE appointments(appointment_id SERIAL PRIMARY KEY, customer_id INT REFERENCES customers(customer_id), service_id INT REFERENCES services(service_id), time VARCHAR(20));

# INSERT INTO services(name) VALUES('Hair cut');
# INSERT INTO services(name) VALUES('Hair dyeing');
# INSERT INTO services(name) VALUES('Nail painting');

# touch salon.sh
# chmod +x ./salon.sh

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  echo -e "\nHow may I help you?"
  echo -e "\nPlease choose from the following services:"
  echo -e "\n1) Hair cut\n2) Hair dyeing\n3) Nail painting\n4) Exit\n"
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
    1 | 2 | 3) SET_APPOINTMENT $SERVICE_ID_SELECTED ;; # Hair cut | Hair Dyeing | Nail painting
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

EXIT(){
  echo -e "\nThank you for choosing us!\nSee you next time! :)\n"
}

SET_APPOINTMENT(){
  # Identify customer
  echo -e "\nWhat's your phone number? "
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # Get name if customer doesn't exist yet
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat is your name? "
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # Get time slot
  echo -e "\nPlease enter a time slot: "
  read SERVICE_TIME
  
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$1', '$SERVICE_TIME')")
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$1'")
  
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  
  EXIT
}

MAIN_MENU
