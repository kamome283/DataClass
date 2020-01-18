import Dataclass;

class Main {
    static public function main() {
        final p1 = new Person("Tsubasa", 24);
        trace(p1.title);
        trace(p1.name);
        trace("Hello, World!");
    }
}

@:build(Dataclass.constructor())
@:build(Dataclass.makePublic())
class Person {
    final name: String;
    final age: Int;
    public var title(get, never): String;
    inline private function get_title()
        return '${name}(${age})';
}