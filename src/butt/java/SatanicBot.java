package butt.java;

import org.jibble.pircbot.PircBot;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import java.io.IOException;

/**
 * @author SatanicSanta
 */
public class SatanicBot extends PircBot {

  public SatanicBot(){
    this.setName("SatanicBot");
  }

  public void onMessage(String channel, String sender, String login, String host, String msg, String name, String abbrv){
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("python");
    if (msg.equals("!abbrev")){
      sendMessage(channel, sender + ": Recorded Name as '" + name + "' and the abbrev as '" + abbrv + "'.");
    }
  }
}

/*
I need to make the bot get CSV with the !abbrev command. This command will run a modified version of abbrv.py. It will
then upload the results to Puush. Finally, it will send the user the Puush link. Eventualy it will directly change the
Wiki page.
*/
