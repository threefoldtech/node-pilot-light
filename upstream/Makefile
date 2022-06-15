EXEC = tfnp.so
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

CFLAGS += -shared -fPIC
LDFLAGS += -shared -fPIC -ldl

all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	$(RM) *.o

mrproper: clean
	$(RM) $(EXEC)

