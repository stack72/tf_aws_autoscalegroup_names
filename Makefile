account?=default
.PHONEY: all

all: clean variables.tf.json

variables.tf.json:
	ruby getvariables.rb -a $(account)

clean:
	rm -f variables.tf.json
