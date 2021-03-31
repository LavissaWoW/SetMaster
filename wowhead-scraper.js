// ==UserScript==
// @name         New Userscript
// @namespace    http://wowhead.com/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://www.wowhead.com/transmog-set=*
// @grant        none
// ==/UserScript==

(function() {
    var btnParent = document.getElementsByClassName("db-action-buttons")[0]
var btn = document.createElement("a")
btn.innerText = "Next"
btn.className = "btn btn-small"
btn.href = "javascript:;"
btn.onclick = goToNext
btnParent.appendChild(btn)
})();

(function() {
    console.log(document.getElementById("transmog"))
    console.log(document.getElementsByClassName("db-action-buttons")[0])
var btnParent = document.getElementsByClassName("db-action-buttons")[0]
var btn = document.createElement("a")
btn.innerText = "Copy"
btn.className = "btn btn-small"
btn.href = "javascript:;"
btn.onclick = getSetInfo
btnParent.appendChild(btn)
})();

function goToNext() {
    var wowheadID = parseInt(window.location.href.match(/(\d+)/)[0])
    window.location.href = "https://www.wowhead.com/transmog-set="+(wowheadID+1)
}

function getSetInfo() {
    var armorType = 0
    document.getElementsByClassName("first last")[0].childNodes.forEach(function(li){
        if(li.childNodes[0].innerText.search("Type: ") == 0){
            armorType = armorTypes[li.innerText.split(": ")[1]]
        }})
    var wowheadID = 800000+parseInt(window.location.href.match(/(\d+)/)[0])
	var name = document.getElementsByClassName("heading-size-1")[0].innerText
    var splitName = name.split("(")
    name = splitName[0]
    console.log(splitName.length > 1)
    if (splitName.length > 1) {
        name = name.slice(0, -1)
    }
	var slotList = document.getElementById("transmog")
	var setInfo = '{\n\tname = "'+name+'",\n\tdescription = "",\n\tsetID = '+wowheadID+',\n'+((splitName.length > 1) ? "\tbaseSetID = -1,\n" : "")+'\tminRequiredLevel = 1,\n\trequiredClassMask = 0,\n\texpansionID = ?,\n'
	setInfo = setInfo + "\tarmorType = "+armorType+",\n\tlimitedTimeSet = false,"
	var setItems = "\t{\n\t"

	slotList.childNodes.forEach(function(slot){
		var slotNodes = slot.getElementsByTagName("UL")[0]
        var slotName = slot.getElementsByTagName("H2")[0]
		var slotNumber = itemSlots[slotName.innerText]
		var slotItems = "{"
		slotNodes.childNodes.forEach(function(item) {
			if (item.nodeName == "LI") {
				if (slotItems.length > 1) {
					slotItems = slotItems + ", "
				}
				var itemNode = item.childNodes[2].href
				var itemNumber = itemNode.split("=")[1]
				slotItems = slotItems + itemNumber
			}
		})
		slotItems = "\t[" + slotNumber + "] = " + slotItems + "},\n\t"
		setItems = setItems + slotItems
	})
	setItems = setItems + "}"
	setInfo = setInfo + "\n\titems = \n" + setItems
	setInfo = setInfo+"\n}"
    copyStringToClipboard(setInfo)
}

var itemSlots = {
	'Head': 1,
	'Shoulder': 3,
	'Shirt': 4,
	'Chest': 5,
	'Belt': 6,
	'Waist': 6,
	'Legs': 7,
	'Feet': 8,
	'Wrist': 9,
	'Gloves': 10,
	'Hands': 10,
	'Back': 15,
	'Main Hand': 16,
	'Off Hand': 17,
	'Ranged': 18,
	'Tabard': 19

}

var armorTypes = {
   	'Cloth': 1,
	'Leather': 2,
	'Mail': 3,
	'Plate': 4,
	'All': 5
}

function copyStringToClipboard (str) {
   // Create new element
   var el = document.createElement('textarea');
   // Set value (string to be copied)
   el.value = str;
   // Set non-editable to avoid focus and move outside of view
   el.setAttribute('readonly', '');
   el.style = {position: 'absolute', left: '-9999px'};
   document.body.appendChild(el);
   // Select text inside element
   el.select();
   // Copy text to clipboard
   document.execCommand('copy');
   // Remove temporary element
   document.body.removeChild(el);
}