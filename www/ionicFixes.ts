import insertionQ from 'insertion-query'

function clean(node)
{
    for(var n = 0; n < node.childNodes.length; n ++)
    {
        var child = node.childNodes[n];
        if
        (
        child.nodeType === 8 
        || 
        (child.nodeType === 3 && !/\S/.test(child.nodeValue))
        )
        {
        node.removeChild(child);
        console.log("removed a superflous node:", child, "from", node);
        n --;
        }
        else if(child.nodeType === 1)
        {
        clean(child);
        }
    }
}

insertionQ('ion-footer, ion-header').every(function(element){
    clean(element)
});