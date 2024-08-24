const SlashCommand = require("../../lib/SlashCommand");
const prettyMilliseconds = require("pretty-ms");
const { EmbedBuilder, ActionRowBuilder, StringSelectMenuBuilder } = require("discord.js");
const { embedNoLLNode, redEmbed, colorEmbed } = require("../../util/embeds");

const command = new SlashCommand()
  .setName("search")
  .setDescription("Search for a song")
  .addStringOption((option) =>
    option
      .setName("query")
      .setDescription("The song to search for")
      .setRequired(true)
  )
  .setRun(async (client, interaction, options) => {
    let channel = await client.getChannel(client, interaction);
    if (!channel) {
      return;
    }

    let player;
    if (client.manager.Engine) {
      player = client.manager.Engine.createPlayer({
        guildId: interaction.guild.id,
        voiceChannel: channel.id,
        textChannel: interaction.channel.id,
      });
    } else {
      return interaction.reply({
        embeds: [embedNoLLNode()],
      });
    }
    await interaction.deferReply().catch((_) => {});

    if (player.state !== "CONNECTED") {
      player.connect();
    }

    const search = interaction.options.getString("query");
    let res;

    const sendRedEmbed = (
      desc = "An error occured while searching for the song"
    ) => {
      return interaction.reply({
        embeds: [
          redEmbed({
            desc,
          }),
        ],
        ephemeral: true,
      });
    };

    try {
      res = await player.search(search, interaction.user);
      if (res.loadType === "LOAD_FAILED") {
        return sendRedEmbed();
      }
    } catch (err) {
      return sendRedEmbed();
    }

    if (res.loadType == "NO_MATCHES") {
      return sendRedEmbed(`No results found for \`${search}\``);
    } else {
      let max = 10;
      if (res.tracks.length < max) {
        max = res.tracks.length;
      }

      let resultFromSearch = [];

      res.tracks.slice(0, max).map((track) => {
        resultFromSearch.push({
          label: `${track.title}`,
          value: `${track.uri}`,
          description: track.isStream
            ? `LIVE`
            : `${prettyMilliseconds(track.duration, {
                secondsDecimalDigits: 0,
              })} - ${track.author}`,
        });
      });

      const menus = new ActionRowBuilder().addComponents(
        new StringSelectMenuBuilder()
          .setCustomId("select")
          .setPlaceholder("Select a song")
          .addOptions(resultFromSearch)
      );

      let choosenTracks = await interaction.editReply({
        embeds: [
          colorEmbed({
            color: client.config.embedColor,
            desc: `Here are some of the results I found for \`${search}\`. Please select track within \`30 seconds\``,
          }),
        ],
        components: [menus],
      });
      const filter = (button) => button.user.id === interaction.user.id;

      const tracksCollector = choosenTracks.createMessageComponentCollector({
        filter,
        time: 30000,
      });
      tracksCollector.on("collect", async (i) => {
        if (i.isSelectMenu()) {
          await i.deferUpdate();
          let uriFromCollector = i.values[0];
          let trackForPlay;

          trackForPlay = await player?.search(
            uriFromCollector,
            interaction.user
          );
          player?.queue?.add(trackForPlay.tracks[0]);
          if (!player?.playing && !player?.paused && !player?.queue?.size) {
            player?.play();
          }
          i.editReply({
            content: null,
            embeds: [
              new EmbedBuilder()
                .setAuthor({
                  name: "Added to queue",
                  iconURL: client.config.iconURL,
                })
                .setURL(trackForPlay.tracks[0].uri)
                .setThumbnail(trackForPlay.tracks[0].displayThumbnail("maxresdefault"))
                .setDescription(
                  `[${trackForPlay?.tracks[0]?.title}](${trackForPlay?.tracks[0].uri})` ||
                    "No Title"
                )
                .addFields(
                  {
                    name: "Added by",
                    value: `<@${interaction.user.id}>`,
                    inline: true,
                  },
                  {
                    name: "Duration",
                    value: trackForPlay.tracks[0].isStream
                      ? `\`LIVE :red_circle:\``
                      : `\`${client.ms(trackForPlay.tracks[0].duration, {
                          colonNotation: true,
                        })}\``,
                    inline: true,
                  }
                )
                .setColor(client.config.embedColor),
            ],
            components: [],
          });
        }
      });
      tracksCollector.on("end", async (i) => {
        if (i.size == 0) {
          choosenTracks.edit({
            content: null,
            embeds: [
              colorEmbed({
                color: client.config.embedColor,
                desc: `No track selected. You took too long to select a track.`,
              }),
            ],
            components: [],
          });
        }
      });
    }
  });

module.exports = command;
