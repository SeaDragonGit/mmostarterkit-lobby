
unityObjectUrl = "http://webplayer.unity3d.com/download_webplayer-3.x/3.0/uo/UnityObject2.js"
		
if (document.location.protocol == 'https:')
  unityObjectUrl = unityObjectUrl.replace("http://", "https://ssl-")
		
document.write('<script type="text\/javascript" src="' + unityObjectUrl + '"><\/script>')
		

$(document).ready ->
  $missingScreen = jQuery("#unityPlayer").find(".missing")
  $brokenScreen = jQuery("#unityPlayer").find(".broken")
  $missingScreen.hide()
  $brokenScreen.hide()
  
  $brokenScreen.find("a").click (e) ->
	  e.stopPropagation()
	  e.preventDefault()
	  u.installPlugin()
	  false
    
  $missingScreen.find("a").click (e) ->
    e.stopPropagation()
    e.preventDefault()
    u.installPlugin()
    false
  
  config = {
    width: 760
    height: 600
    params: 
      enableDebugging:"0"
  }
  
  u = new UnityObject2(config)
  
  u.observeProgress (progress) =>
    switch progress.pluginStatus
      when "broken" then $brokenScreen.show()
      when "missing" then $missingScreen.show()
      when "installed" then $missingScreen.remove()
      when "first" then u.getUnity().SendMessage("ClientDispatcher","SetFacebookUserID",window.fbUserId)
      
    false
  u.initPlugin(jQuery("#unityPlayer")[0], "/MMOStarterKitWebClient.unity3d");  
      