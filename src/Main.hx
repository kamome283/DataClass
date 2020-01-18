import Dataclass;

class Main {
    static public function main() {
        final p1 = new Person("Tsubasa", 24);
        trace(p1.title);
        trace("Hello, World!");
    }
}

@:build(Dataclass.constructor())
class Person {
    public final name: String;
    public final age: Int;
    public var title(get, never): String;
    inline private function get_title()
        return '${name}(${age})';
}