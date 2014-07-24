shared abstract class BooleanTerm() of BinaryTerm<BooleanTerm,BooleanTerm> | True | False
		satisfies Visitable<BooleanTerm, BooleanTerm> {}

shared abstract class BinaryTerm<out Left = BooleanTerm,out Right = BooleanTerm>(left, right)
		of And<Left,Right> | Or<Left,Right>
		extends BooleanTerm()
		satisfies Visitable<BinaryTerm, BooleanTerm>
		given Left satisfies BooleanTerm
		given Right satisfies BooleanTerm {
	default shared Left left;
	default shared Right right;
}

shared class And<out Left = BooleanTerm,out Right = BooleanTerm>(left, right) extends BinaryTerm<Left,Right>(left, right)
		satisfies Visitable<And, BooleanTerm>
		given Left satisfies BooleanTerm
		given Right satisfies BooleanTerm {
	shared actual Left left;
	shared actual Right right;
	shared actual String string => "``left`` and ``right``";
	shared variable actual {BooleanTerm*} children = {left, right};
	shared actual And<Left,Right> node => this;
}

shared class Or<out Left = BooleanTerm,out Right = BooleanTerm>(left, right) extends BinaryTerm<Left,Right>(left, right)
		given Left satisfies BooleanTerm
		given Right satisfies BooleanTerm {
	shared actual Left left;
	shared actual Right right;
	shared actual String string => "(``left`` or ``right``)";
	shared variable actual {BooleanTerm*} children = {left, right};
	shared actual Or<Left,Right> node => this;
}

shared abstract class True() of myTrue extends BooleanTerm() {
	shared variable actual {BooleanTerm*} children = {};
	shared actual True node => this;
}

shared abstract class False() of myFalse extends BooleanTerm() {
	shared variable actual {BooleanTerm*} children = {};
	shared actual False node => this;
}

shared object myTrue extends True() {
	shared actual String string => "true";
}
shared object myFalse extends False() {
	shared actual String string => "false";
}



BinaryTerm expr1 = And(Or(myFalse, And(myTrue, myTrue)), myTrue);

void testMatchAndRules() {
	value r = Rule {
		when(And t) => t.left == myFalse || t.right == myFalse;
		do(And t) => myFalse;
	};
	
	value toApply = r.apply(expr1);
	if (exists toApply) {
		toApply();
	}
	
	value simplifier = Match {
		Rule {
			when(And t) => t.left == myFalse || t.right == myFalse;
			do(And t) => myFalse;
		},
		Rule {
			when(And t) => t.left == myTrue;
			do(And t) => t.right;
		},
		Rule {
			when(And t) => t.right == myTrue;
			do(And t) => t.left;
		},
		Rule {
			when(Or t) => t.left == myTrue || t.right == myTrue;
			do(Or t) => myTrue;
		},
		Rule {
			when(Or t) => t.left == myFalse;
			do(Or t) => t.right;
		},
		Rule {
			when(Or t) => t.right == myFalse;
			do(Or t) => t.left;
		}
	};
	
	value formatter = Match {
		Rule {
			when(And t) => true;
			void do(And t) {
				print(t);
			}
		},
		Rule {
			when(BooleanTerm t) => true;
			void do(BooleanTerm t) {
				print(t);
			}
		},
		Rule {
			when(And t) => t.left == myTrue;
			do = (And t) => t.right;
		},
		Rule {
			when(And t) => t.right == myTrue;
			do = (And t) => t.left;
		},
		Rule {
			when(Or t) => t.left == myTrue || t.right == myTrue;
			do = (Or t) => myTrue;
		},
		Rule {
			when(Or t) => t.left == myFalse;
			do = (Or t) => t.right;
		},
		Rule {
			when(Or t) => t.right == myFalse;
			do = (Or t) => t.left;
		}
	};
	
	variable BooleanTerm? expr = expr1;
	
	while (!(expr is False || expr is True)) {
		expr = simplifier.apply(expr);
	}
	print(expr);
	
	value t = formatter.apply(expr1);
	print(t);
}

void testVisitors() {
	print("TopDown");
	TopDown(Apply(void(BooleanTerm n) => print(n))).visit(expr1);
	print("BottomUp");
	BottomUp(Apply(void(BooleanTerm n) => print(n))).visit(expr1);
	print("DownUp");
	DownUp {
		down = Apply(void(BooleanTerm n) => print("Down : ``n``"));
		up = Apply(void(BooleanTerm n) => print("Up : ``n``"));
	}.visit(expr1);
	
	print("Descendant");
	Descendant {
		condition(BooleanTerm t) => (t is And<True,True>);
		action = Apply(void(BooleanTerm n) => print("Descendant : ``n``"));
	}.visit(expr1);
	
}


"Run the module `com.serli.ceylon.matcher`."
void run() {
	testMatchAndRules();	
	testVisitors();
}


