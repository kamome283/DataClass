using Dataclass;

class Main {
    static public function main() {
        final p1 = Person.init("Tsubasa", 24);

        final p2 = p1.copy({name: "Kana"});
        trace(p2.title);

        final p3 = p1.copy({});
        trace(p1.equals(p3));
        trace(p1.equals(p2));
    }
}


@:build(Dataclass.constructor())
@:build(Dataclass.makePublic())
@:build(Dataclass.copy())
@:build(Dataclass.equals())
@:build(Dataclass.init())
class Person {
    final name: String;
    final age: Int;
    public var title(get, never): String;
    inline private function get_title()
        return '${name}(${age})';
}