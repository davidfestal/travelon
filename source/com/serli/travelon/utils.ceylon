"""
   Logs events and allows their trace to be inspected.
   """
shared class Logger<RootType = Object>(
    """
          information used to initialize the [[Logger]] trace to a sequence of visiting
          events where the visitor visits a sequence of visitable nodes
          """
    [Visitor<RootType>, Visitable<RootType,RootType>+]? initialTrace = null)
        given RootType satisfies Object {
    
    variable [Event<RootType>*] reversedTrace = [];
    
    if (exists initialTrace) {
        value visitor = initialTrace.first;
        value visitables = initialTrace.rest;
        for (visitable in visitables) {
            reversedTrace = [Event(visitor, visitable.node), *reversedTrace];
        }
    }
    
    shared [Event<RootType>*] trace => reversedTrace.reversed;
    
    """
          Log a single event.
          """
    shared void log(Event<RootType> e) {
        reversedTrace = [e, *reversedTrace];
    }
    
    string => "\n".join(trace);
    
    equals(Object o) => (o is Logger<RootType>) then o.string == string else false;
    
    hash => string.hash;
    
    """
          Compute the elapsed time (in milliseconds) between the first and last
          event on the logger's trace.
          """
    shared Integer elapsedTime {
        Integer? startTime = trace.first?.timeStamp;
        Integer? endTime = trace.last?.timeStamp;
        if (exists startTime, exists endTime) {
            return endTime - startTime;
        } else {
            return 0;
        }
    }
}
