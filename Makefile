all:

test: safetest

safetest:
	prove t/*.t
