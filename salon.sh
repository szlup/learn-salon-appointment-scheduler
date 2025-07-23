#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {

  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  else
    echo -e "\n$1 What would you like today?"
  fi

  SERVICE_LIST=$($PSQL "
  SELECT *
  FROM services
  ORDER BY service_id;
  ")

  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send back to main menu
    MAIN_MENU "That is not a valid service."
  
  # get service
  else
    SERVICE_NAME=$($PSQL "
    SELECT name
    FROM services
    WHERE service_id = $SERVICE_ID_SELECTED;
    ")
    
    # if not found
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service."
    
    else
      SCHEDULING_MENU $SERVICE_ID_SELECTED $SERVICE_NAME
    fi

  fi

}

SCHEDULING_MENU() {
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # look up customer
  CUSTOMER_NAME=$($PSQL "
  SELECT name
  FROM customers
  WHERE phone = '$CUSTOMER_PHONE';
  ")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get CUSTOMER_NAME
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert into customers DB
    INSERT_CUSTOMER_RESULT=$($PSQL "
    INSERT INTO customers (phone, name)
    VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');
    ")
  fi

  # get time
  echo -e "\nWhat time would you like your $2, $(echo $CUSTOMER_NAME | sed 's/^ +| +$//g')?"
  read SERVICE_TIME

  # insert into appointments DB
  CUSTOMER_ID=$($PSQL "
  SELECT customer_id
  FROM customers
  WHERE phone = '$CUSTOMER_PHONE';
  ")

  INSERT_APPOINTMENT_RESULT=$($PSQL "
  INSERT INTO appointments (customer_id, service_id, time)
  VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME');
  ")  
  
  # send confirmation
  echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ +| +$//g')."

}


MAIN_MENU