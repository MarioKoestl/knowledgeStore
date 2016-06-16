# Makefile
CC=g++
CFLAGS=-I -wAll -pedantic

ODIR=obj

_OBJ = MassSpec.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

# compile object files
$(ODIR)/%.o: %.cpp
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

# compile program
MassSpec: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -rf obj/ *~ 
# End of file
