using Dataclass;

class Main {
    static public function main() {
        final p1 = new Person("Tsubasa", 24);
        final p2 = p1.copy({name: "Kana"});
        trace(p2.title);
    }
}


@:build(Dataclass.constructor())
@:build(Dataclass.makePublic())
@:build(Dataclass.copy())
class Person {
    final name: String;
    final age: Int;
    public var title(get, never): String;
    inline private function get_title()
        return '${name}(${age})';
}