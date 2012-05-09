/* Interface to YUI TreeView object to easily define a tree */
/* By JavaScriptKit.com- http://www.javascriptkit.com       */
/* Last updated: Dec 13th, 2006                             */

function jktreeview(treeid){
	this.treetop=new YAHOO.widget.TreeView(treeid)
}

jktreeview.prototype.addItem=function(itemText, noderef, href){
	var noderef=(typeof noderef!="undefined" && noderef!="")? noderef : this.treetop.getRoot()
	var treebranch=new YAHOO.widget.TextNode(itemText, noderef, false)
	if (typeof href!="undefined")
		treebranch.href=href
	return treebranch
}
