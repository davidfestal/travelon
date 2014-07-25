import ceylon.language.meta.declaration {
	ValueDeclaration
}
import ceylon.language.meta {
	type
}

"""
   Describes a node that can be visited by a [[Visitor]], as well as the immediate children that should be visited by the visitor.
   The `children` iterable might be overwritten when the [[Visitable]] is visited by a [[Visitor]]
   """
shared interface Visitable<out NodeType,RootType>
		given NodeType satisfies Object
		given RootType satisfies Object {
	"""
	   The given node
	   """
	shared formal NodeType node;
	"""
	   The [[Iterable]] allowing to retrieve its children.
	   It might be overwritten through [[updateChildren]] when the [[Visitable]] is visited by a [[Visitor]].
	   """
	shared formal {RootType*} children;
	
	"""
	   Used by Visitors to change the children that will be visited by the following visitor.
	   """
	shared formal void updateChildren({RootType*} newChildren);

	"""
	   Reset the children to the initial children of the node.
	   """
	shared formal void resetChildren();
}


"""
   Given a general-purpose object satisfying [[RootType]], the [[Walker]] produced a [[Visitable]] instance that contains ::
     - the given node,
     - an iterable allowing to retrieve its children. The `children` iterator might be overwritten when visited by a [[Visitor]].
   """

shared interface Walker<RootType>
		given RootType satisfies Object {	
	shared formal Visitable<NodeType, RootType> walk<NodeType>(NodeType node)
			given NodeType satisfies RootType;
}

"""
   General-purpose [[Walker]] that, given a [[RootType]] node, returns a [[Visitable]] 
   whose children are the ordered values of the all corresponding class shared 
   parameters that satisfy [[RootType]]
   
   So for an instance `node` of a class :
   ```
   class NodeClass(NodeClass hidden, 
                   shared NodeClass child1, 
                   shared String name, 
                   shared NodeClass child2)
   ```
   the children of the [[Visitable]] produced by the [[MetaModelBasedWalker]] are
   `child1` and `child2`
   
   In the future it might be interesting to also consider that the items of a sequence would be children of this sequence
   """
shared class MetaModelBasedWalker<RootType = Object>() satisfies Walker<RootType>
		given RootType satisfies Object {
	shared actual Visitable<NodeType, RootType> walk<NodeType>(NodeType parent)
			given NodeType satisfies RootType {
		// TODO : in the case of a sequential or Iterable, walk through the members.
		value classModel = type(parent);
		object visitable
				satisfies Visitable<NodeType, RootType> {
			node = parent;
			value _initialChildren = Array { for (param in classModel.declaration.parameterDeclarations) 
				if (param.shared, is ValueDeclaration val = param, is RootType child = val.memberGet(node)) child };
			variable {RootType*} _children = _initialChildren;
			children => _children;
			shared actual void updateChildren({RootType*} newChildren) {
				_children = newChildren;
			}
			resetChildren() => _children = _initialChildren;
			
		}
		return visitable;
	}
}

shared abstract class Failure() of failure {}
shared object failure extends Failure() {}

"""
   Any visitor class should extend the Visitor class.
   
   [[RootType]] is the type satisfied by all the nodes the visitor can visit.
   """
shared abstract class Visitor<RootType>()
		given RootType satisfies Object {
	shared default variable Walker<RootType> walker = MetaModelBasedWalker<RootType>();
	
	"""
	   Pay a visit to any node.
	   This is the only visit method that should be called by clients
	   On the contrary it should not be called by calling visitors
	   """
	shared Visitable<NodeType,RootType>|Failure visit<NodeType>(
		"""
		   The node being visited.
		   If it doesn't implement the [[Visitable]] interface, the [[walker]] will be used to produce one.
		   """
		NodeType|Visitable<NodeType, RootType> node)
			given NodeType satisfies RootType {
		if (is Visitable<NodeType, RootType> node) {
			node.resetChildren();
		}
		return internalVisit<NodeType>(node);
	}
    
	"""
	   Same as [[doVisit]] but convert the node to a Visitable if necessary.
	   This is the method can be called by calling visitors, but not by client code
	   """
	shared Visitable<NodeType,RootType>|Failure internalVisit<NodeType>(
		"""
		   The node being visited.
		   If it doesn't implement the [[Visitable]] interface, the [[walker]] will be used to provide one.
		   """
		NodeType|Visitable<NodeType, RootType> node)
			given NodeType satisfies RootType {
		Visitable<NodeType, RootType> visitable;
		if (is Visitable<NodeType, RootType> node) {
			visitable = node;
		}
		else {
			assert (is NodeType node);
			visitable = walker.walk(node);
		}
		return doVisit(visitable);
	}

	"""
	   Pay a visit to a visitable.
	   This method must be implemented by concrete visitors
	   """
	shared formal Visitable<NodeType,RootType>|Failure doVisit<NodeType>(Visitable<NodeType,RootType> node)
			given NodeType satisfies RootType;
}

"""
   A class to represent a visting event: the fact that a visitable
   node is visited by a particular visitor.
   """ 
shared class Event<RootType = Object>(visitor, node)
		given RootType satisfies Object {
	Visitor<RootType> visitor;
	RootType node;
	shared Integer timeStamp = system.milliseconds;
	
	string => "`` visitor ``.visit( `` node `` )";
	
	shared actual Boolean equals(Object that) {
		if (is Event that) {
			return string == that.string;
		}
		else {
			return false;
		}
	}
	
	hash => string.hash;
}