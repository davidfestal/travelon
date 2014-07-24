## The Travelon visitor combinator framework
 
This module provides a generic visitor combinators for Ceylon.
It is a Ceylon port of the Java-based [JJTraveler project](https://github.com/cwi-swat/jjtraveler).
Ceylon powerful generics implementation, as well as it high-order programmong support, allow providing 
visitor combinators in a way that is quite easy to use.

## What are visitor combinators ?

The notion of visitor combinators was first introduced in _Visitor Combination and Traversal Control_
(Joost Visser, OOPSLA 2001).
Visitor combinators are small, reusable classes that implement a _generic_ visitor interface.
Here, _generic_ means: independent of any specific class hierarchy. Each combinator captures a basic 
piece of functionality. They can be composed in different constellations to build more complex visitors.

## The Ceylon-specific implementation

... To be continued

## How to use :
 
Given the following class hierarchy :
```Ceylon
abstract class Node(String name) 
   of BinaryNode | Leaf {
   string => name;
}
class Leaf(String name)
   extends Node(name) {}
class BinaryNode(String name, left, right) 
   extends Node(name) {
   shared Node left;
   shared Node right;
}
```
... and the following object :
```Ceylon
value tree = BinaryNode("0", 
                BinaryNode("1", 
                    Leaf("1.1"),
                    Leaf("1.2")),
                BinaryNode("2", 
                    Leaf("2.1"),
                    Leaf("2.2")));
```
The following visitor :
```Ceylon
value visitor = TopDown(Apply(void(Node n) => print(n)));
```
can be applied on the tree :
```Ceylon
visitor.visit(tree);
```
and will print :
```
0
1
1.1
1.2
2
2.1
2.2
```

You can apply the visitors to 2 kinds of objects :
 - Objects that implement the `Visitable` interface.
 - General-purpose objects. In this case, a `Visitable` is produced for each visited node through the `Walker` of the visitor. the default Walker is the `MetaModelBasedWalker`.
 
Other examples using nodes that satisfiy the `Visitable` interface can be found in the tests, or in the `testVisitors` method of this module (in the `run.ceylon` file).

Additional walkers might be added in the future to accomodate specific trees, such as `ceylon.ast` trees, XML files, etc ...   
