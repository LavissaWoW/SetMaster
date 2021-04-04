const fetch = require("node-fetch");
const jsdom = require("jsdom");
const fs = require("fs");
const { JSDOM } = jsdom;
const WHNumSets = 2854;
var setCategories = ["?filter=3;1;0", "?filter=3;2;0", "?filter=3;3;0", "?filter=3;4;0", "?filter=3;5;0", "?filter=3;6;0", "?filter=3;7;0", "?filter=3;8;0", "?filter=3;9;0"]
var dropSources = ["/source:1", "/source:2", "/source:4", "/source:8", "/source:16"];
var classURLs = ["death-knight", "demon-hunter", "druid", "hunter", "mage", "monk", "paladin", "priest", "rogue", "shaman", "warlock", "warrior"];
var allSets = {};
var terminate = 0;

// Henter info fra et predefinert sett med websider.
// Populerer allSets
async function getAllSets() {
    for(const category of setCategories) {
        (async () => {
            const response = await fetch("http://www.wowhead.com/transmog-sets"+category);
            const text = await response.text();
            if(toomanyResults(text)) {
                for(const classURL of classURLs) {
                    (async () => {
                        const response = await fetch("http://www.wowhead.com/"+classURL+"-transmog-sets"+category);
                        const text = await response.text();
                        parseSets(text, category);
                    })()
                }
            } else {
                parseSets(text, category);
            }
        })()
    }    
}

// Finner nærmere informasjon om et sett med en gitt ID fra allSets
async function getSetInfo(setID) {
    const response = await fetch("http://www.wowhead.com/transmog-set="+setID);
    const text = await response.text();
    const dom = await new JSDOM(text);
    const document = dom.window.document;

    var lookalikes = text.match(/new Listview\(\{\n(?:.+\n)+\s+data:(\[.+;)/);
    
    if(lookalikes) {
        lookalikes = lookalikes[1];
        lookalikes = lookalikes.slice(0, -3);
        const sets = JSON.parse(lookalikes);
    
        for(const set of sets) {
            const splitName = set.name.split("(");
            if(splitName.length == 1) {
                if(allSets[setID].baseSet != null) {
                    console.log("Several basesets discovered for setID "+setID)
                } else {
                    allSets[setID].baseSetID = set.id;
                }
            }
        }    
    }

    const splitName = allSets[setID].name.split("(");
    var name = splitName[0];
    if (splitName.length > 1) {
        name = name.slice(0, -1);
        allSets[setID].name = name;
    }

    const slotList = document.getElementById("transmog");
    if (slotList.childNodes.length > 0) {
        allSets[setID].items = {};
    }
    // Dette er DOM, og har en egen forEach func
    slotList.childNodes.forEach((slot) => {
        const slotNodes = slot.getElementsByTagName("UL")[0];
        const slotID = slot.getElementsByTagName("H2")[0].getElementsByTagName("Span")[0].getAttribute("data-inventory-type");
        slotNodes.childNodes.forEach((item) => {
            if(item.nodeName == "LI") {
                if(!allSets[setID].items[slotID]) {
                    allSets[setID].items[slotID] = []
                }
                if (item.childNodes[4].className == "q0" || item.childNodes[4].className == "q1") {
                    return;
                }
                const itemURL = item.childNodes[2].href;
                const itemID = itemURL.split("=")[1];
                allSets[setID].items[slotID].push(itemID);    
            }
        })
    })

    console.log(allSets[setID])
    
}

// Skriver en string som er valid syntax i Lua. 
// All info skal portes til en .lua-fil til slutt.
async function writeLuaString(set) {
    var luaString = "{"
    luaString = luaString + 'name="'+set.name+'",';
    luaString = luaString + 'description="",';
    luaString = luaString + 'setID='+set.id+',';
    luaString = luaString + (set.baseSetID ? 'baseSetID='+set.baseSetID+',' : '');
    luaString = luaString + 'minRequiredLevel=1,';
    luaString = luaString + 'requiredClassMask=0,';
    luaString = luaString + 'expansionID='+set.expansionID+',';
    luaString = luaString + 'armorType='+set.armorType+',';
    luaString = luaString + 'limitedTimeSet=false,';
    luaString = luaString + 'items={'
    for(const slot in set.items) {
        luaString = luaString + '['+slot+']='+JSON.stringify(set.items[slot]).replaceAll('"', "").replaceAll("[", "{").replaceAll("]", "}")+','
    }
    luaString = luaString.slice(0, -1);
    luaString = luaString + '}'
    luaString = luaString + '}'
    //console.log(luaString);
    return luaString;
}

// Websiden begrenser antall resultater til 500.
// Dersom dette skjer, så legger jeg til flere filter parameters.
function toomanyResults(text) {
    return text.search("Try filtering your results") >= 0;
}

// Parser http-responsen for et JSON-objekt som parses og lagres
function parseSets(text, expFilter) {
    var setString = text.match(/var transmogSets = (.+)/)[1];
    setString = setString.slice(0, -1);
    const sets = JSON.parse(setString);
    const expansionID = setCategories.findIndex((element) => element == expFilter);
    sets.forEach(function(elem) {
        elem.expansionID = expansionID + 1;
        if (!allSets[elem.id]) {
            allSets[elem.id] = elem;
        }
    });
    //console.log(Object.keys(allSets).length) // FOR DEBUG

    // Terminerer while-loopen i main
    if (Object.keys(allSets).length == WHNumSets) {
        terminate = 1;
        return 1
    } else {
        return 0
    }
}

function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
    getAllSets();
//    terminate = 1; // FOR DEBUG
    while(!terminate) {
        console.log("wh")
        await sleep(100);
    }
    const debugCount = 10
    var count = 0;
    for(const set in allSets) {
        if(count > debugCount){break}
        console.log(allSets[set])
        await getSetInfo(allSets[set].id);
        count = count + 1;
    }
    count = 0;
    fs.appendFile("luasets.lua", "DB.sets={", function(err){if(err){throw err}})
    for(const set in allSets) {
        if(count > debugCount){break}
        const luaString = await writeLuaString(allSets[set]);
        fs.appendFile("luasets.lua", luaString+',\n', function(err){if(err){throw err}})
        count = count + 1;
    }
    fs.appendFile("luasets.lua", "}", function(err){if(err){throw err}})
}

main();