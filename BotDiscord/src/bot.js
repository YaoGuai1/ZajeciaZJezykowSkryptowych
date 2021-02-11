require('dotenv').config();

const PREFIX = "$";
const { Client, WebhookClient } = require('discord.js');
const client = new Client({
    partials: ['MESSAGE', 'REACTION'] //obsługa niecacheowanych elementów
});

const webhookClient = new WebhookClient(
    process.env.WEBHOOK_ID,
    process.env.WEBHOOK_TOKEN
);

client.on('ready', () => {
    console.log(`${client.user.username} has looged in`)
})


client.on('message', async(message) => {
    console.log(`${message.author.tag}: ${message.content}`);

    if (message.author.bot)
        return;

    //OBSLUGA KOMEND

    if (message.content.startsWith(PREFIX)){

        //lista gdzie pierwszy element to komenda a następne to lista argumentów args
        const [COMAND_NAME, ...args] = message.content
            .trim()
            .substring(PREFIX.length)
            .split(/\s+/); //dzielenie po dowolnej ilości spacji

        //KICK
        if (COMAND_NAME === 'kick'){
            if(!message.member.hasPermission('KICK_MEMBERS'))
                return message.reply('You do not have permisions to kick users')
            if (args.length === 0)
                return message.reply('Please provide user ID to kick');

            const member = message.guild.members.cache.get(args[0]);
            console.log(message.guild.members);
            if (member) {
                member
                    .kick()
                    .then((member) => message.channel.send(`Kicked the user with ID: ${member} successfully`))
                    .catch((err) => message.channel.send('I cannot permision to kick that user'));
            }else{
                message.channel.send('Member ID not found in the guild');
            }
        }

        //BAN
        else if (COMAND_NAME === 'ban'){
            if(!message.member.hasPermission('BAN_MEMBERS'))
                return message.reply('You do not have perrmisions to ban users from server')
            if (args.length === 0)
                return message.reply('Please provide user ID to ban');

            //inny sposób, tym razem użycie try catch
            try{
                const user = await message.guild.members.ban(args[0]);
                message.channel.send(`User with ID: ${user} was banned successfully`)
            }catch (err){
                console.log(err);
                message.channel.send(`An error occured: ${err}`)
            }
        }

        //ogłoszenie używając webhooka
        else if(COMAND_NAME === 'announce'){
            const msg = args.join(' ');
            webhookClient.send(msg);
        }
    }
})

//ZARZĄDZANIE ROLAMI

//dodawanie roli przez reakcję
client.on('messageReactionAdd', (reaction, user) => {
    const {name} = reaction.emoji;
    const member = reaction.message.guild.members.cache.get(user.id);
    if (reaction.message.id === '808094028662571060'){
        switch (name){
            case '🍎':
                member.roles.add('808093119031410699');
                break;
            case '🍌':
                member.roles.add('808093046502981653');
                break;
            case '⚽':
                member.roles.add('808093156046012447');
                break;
        }
    }
});

//usuwanie roli poprzez usunięcie reakcji
client.on('messageReactionRemove', (reaction, user) => {
    const {name} = reaction.emoji;
    const member = reaction.message.guild.members.cache.get(user.id);
    if (reaction.message.id === '808094028662571060'){
        switch (name){
            case '🍎':
                member.roles.remove('808093119031410699');
                break;
            case '🍌':
                member.roles.remove('808093046502981653');
                break;
            case '⚽':
                member.roles.remove('808093156046012447');
                break;
        }
    }
});

client.login(process.env.DISCORDJS_BOT_TOKEN);

