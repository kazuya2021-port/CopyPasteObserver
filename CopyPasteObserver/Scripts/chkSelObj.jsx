﻿#target illustrator#targetengine mainfunction isObjectSelected(){    try    {        var doc = app.activeDocument;        var selObj = doc.selection;        if(selObj.length == 0)            return false;        else            return true;    }    catch(e)    {        return false;    }}isObjectSelected();