package butt.java;

/**
 * @author SatanicSanta
 */
public class GucciMane {

    public static void main(String[] args) throws Exception{
        SatanicBot bot = new SatanicBot();
        bot.setVerbose(true);
        bot.connect("irc.esper.net");
        //bot.joinChannel("#FTB-Wiki");
        bot.joinChannel("#SatanicSanta");
    }
}
