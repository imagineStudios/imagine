function lOn = isOn(obj, sTag)

lOn = obj.SMenu(strcmp({obj.SMenu.Name}, sTag)).Active;