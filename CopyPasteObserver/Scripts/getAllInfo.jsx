#target illustrator#targetengine main#include "json2.jsxinc"function getAllObjInfo(){    try{        var doc = app.activeDocument;        var allObj = doc.pageItems;        var allObjJson = [];        var objID = 0        for(i = 0; i < allObj.length; i++)        {            try            {                var o = allObj[i];                if(!o.guides)                {                    if(o.note != "AkaGroup")                    {                        o.note = "scriptSelect" + objID;                        objID++;                    }                    $.writeln(o.typename);                    var myObject;                    if(o.typename == "TextFrame")                    {                        myObject = {note:o.note, position:o.position, contents:o.contents};                    }                    else                    {                        myObject = {note:o.note, position:o.position};                    }                    allObjJson.push(myObject);                }            }            catch(e)            {                $.writeln("error Object:" + objID);            }        }    }    catch(e) {        $.writeln(e);    }    return  JSON.stringify(allObjJson);}getAllObjInfo();