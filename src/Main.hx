using Dataclass;

class Main {
	static public function main() {
		// Generates *private* constructor which takes and initializes all class variables.
		// final yui = new Idol("Yui", 17, Passion);

		// The constructor is private, thus you are required to use "init" method.
		// If you do not implement "init" method, the method is automatically generated, which calls the constructor.
		final yui = Idol.init("Yui", 17, Passion);
		trace(yui.name);

		// Generates "copy" method which takes class variables for change as an anonymous structure.
		// This method constructs a new object with given variables and original variables for not given variables.
		final nao = yui.copy({name: "Nao", type: Cool});
		trace(nao.name);

		// Generates "equals" method which compares structually.
		// Remember that this method just compares all variables with `this.$var == rhs.$var`.
		// Thus if class variables are compared by the reference, this method does not work well.
		final yui_ = yui.copy({});
		trace(yui.equals(yui_));

		// You can unapply the object and use pattern match.
		// This is *default* behavior, not by my macro, but I think this behavior is worth to mention here.
		final s = switch (yui) {
			case {name: "Yui", age: 18}: "Yui(18)";
			case {name: "Yui"}: "Yui(_)"; // Matches this
			default: "_";
		};
		trace(s);
	}
}

// All class variables become public automatically.
class Idol implements DataClass {
	final name:String;
	final age:Int;
	final type:IdolType;
}

enum IdolType {
	Cute;
	Cool;
	Passion;
}
