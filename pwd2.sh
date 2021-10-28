#!/bin/bash
# Generate password depending on the option. First arguement defines if special characters are used or not ( 's' with special, 'r' without special)

read -p 'Enter number of charaters: ' chnum;
read -p "Enter character type. (s - includes special characters, r - does not include special characters) : " chtype;
# Generate with special characters

spec_passgen () {

	tr -cd "[:graph:]" < /dev/urandom \
	| head -c $chnum;
	echo;
	}

# Generate alphanumeric characters

alnum_passgen () {

	tr -cd "a-zA-Z0-9" < /dev/urandom \
	| head -c $chnum;
	echo;

}

# Exception handling
# Handle char type flag

if [[ ! "$chtype" =~ ^('r'|'s')$ ]]; then
	echo -e "Error! Invalid first arguement provided. \n\nAvailable options are: s (with special numbers) r (without special characters)" >&2 && exit 1;
fi

# Handle password lenght arguement

if [[ ( ! "$chnum" =~ ^[[:digit:]]+$ ) || ( ! $chnum > 0 ) ]]; then
        echo 'Error! Please provide a valid number as a second arguement' >&2 && exit 1;
fi


# Generate password itself

if [[ "$chtype" == "s"  ]]; then
	echo $(spec_passgen);
else
	echo $(alnum_passgen);
fi
