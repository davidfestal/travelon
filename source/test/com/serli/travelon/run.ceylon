import com.serli.travelon {
    Logger,
    LogVisitor,
    Visitor
}
import ceylon.test {
    beforeTest
}
"Run the module `test.com.serli.travelon`."
shared void run() {
}

"""
   Nodes in a simple tree that can be used for
   testing traversals.
   Names correspond to paths in the tree:
   ```
           n0
         /    \
       n1     n2
       / \    
    n11  n12
   ```
   """
class Tree(n0, n1, n11, n12, n2) {
    shared Node n0;
    shared Node n1;
    shared Node n11;
    shared Node n12;
    shared Node n2;
}

variable Tree tree = buildTree();
Tree buildTree() {
    value n11 = Node(); // Node-0
    value n12 = Node(); // Node-1
    value n1 = Node([n11, n12]); // Node-2
    value n2 = Node(); // Node-3
    value n0 = Node([n1, n2]); // Node-4
    return Tree(n0, n1, n11, n12, n2);
}

variable Node rootOfDiamond = buildDiamond();
Node buildDiamond() {
    Node sink = Node();
    return Node([sink, sink]);
}

variable Node rootOfCircle = buildCircle();
Node buildCircle() {
    Node node = Node();
    value rootOfCircle = Node([node]);
    node.kids = [rootOfCircle];
    node.resetChildren();
    return rootOfCircle;
}

variable Logger<Node> logger = Logger<Node>();

beforeTest
void setUp() {
    resetNodeCounter();
    buildTree();
    buildDiamond();
    buildCircle();
    logger = Logger<Node>();
}

"""
   Many test cases will need a logging visitor:
   this methods returns one.
   """
LogVisitor<Node> logVisitor(Visitor<Node> v) {
    return LogVisitor(v, logger);
}
