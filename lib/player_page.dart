import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/components/inner_shadow.dart';
import 'package:music_app/components/music_progress_bar.dart';
import 'package:music_app/cubit/controller/controller_cubit.dart';
import 'package:music_app/model/music_model.dart';
import 'package:music_app/model/position_data.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:rxdart/rxdart.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key, required this.viewPadding}) : super(key: key);

  final EdgeInsets viewPadding;

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  ThemeData? theme;
  late AnimationController playAnimationController;
  late Animation<double> playAnimation;
  late TabController _tabController;
  late final CustomSegmentedController<int> _segmentedController;

  late VolumeController volumeController;

  double volume = 0.0;

  Color? mockMusicColor;

  int page = 0;

  bool isEnableVolumeControl = false;
  bool isSubscribed = false;

  void _playPauseOnPressed(ControllerMediaState state) {
    if (state is ControllerPlayingState) {
      context.read<ControllerCubit>().pause(previousState: state);
      playAnimationController.forward();
    } else {
      context.read<ControllerCubit>().play(previousState: state);
      playAnimationController.reverse();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _segmentedController = CustomSegmentedController();

    playAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    playAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(playAnimationController);
    playAnimationController.value = 1;
    volumeController = VolumeController();
    volumeController.showSystemUI = false;
    volumeController.listener((volume) {
      setState(() => this.volume = volume);
    });

    volumeController.getVolume().then((volume) => this.volume = volume);

    //mockColor();
  }

  @override
  void dispose() {
    volumeController.removeListener();

    super.dispose();
  }

  mockColor() async {
    //Color color = await extractColor(music.imageUrl);
    setState(() {
      //mockMusicColor = color;
      //theme = ThemeData(colorSchemeSeed: color, useMaterial3: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    theme ??= Theme.of(context);

    double a = MediaQuery.of(context).viewPadding.top +
        MediaQuery.of(context).viewPadding.bottom;
    double b = (60 + 6) + (76 + 8);

    double c = MediaQuery.of(context).size.height - (a + b);

    if (c >= 670) {
      isEnableVolumeControl = true;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: theme!.colorScheme.surface,
        systemNavigationBarDividerColor: theme!.colorScheme.surface,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme!.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: theme!.colorScheme.secondary.withOpacity(.1),
              blurRadius: 6.0,
              spreadRadius: 2.0,
              offset: const Offset(
                0.0,
                -2.0,
              ),
            ),
          ],
        ),
        margin: const EdgeInsets.only(top: 8),
        child: Scaffold(
          bottomNavigationBar: isSubscribed ? null : bottomToolbar(),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 76,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: theme!.colorScheme.secondaryContainer,
                systemNavigationBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                statusBarColor: Colors.transparent),
            leadingWidth: 0,
            leading: Container(),
            titleSpacing: 0,
            title: Container(
              margin: const EdgeInsets.only(top: 4, left: 20, right: 20),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InnerShadow(
                      shadows: [
                        BoxShadow(
                          color: theme!.colorScheme.secondary.withOpacity(.2),
                          blurRadius: 3.0,
                          spreadRadius: 0.0,
                          offset: const Offset(
                            0.0,
                            2.0,
                          ),
                        ),
                      ],
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            height: 40,
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme!.colorScheme.secondaryContainer
                                      .withOpacity(0.6),
                                ),
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.chevron_down,
                                      size: 20,
                                      color: theme!.colorScheme.secondary,
                                    ),
                                    Container(width: 8),
                                    Text(
                                      "ย่อลง",
                                      style: TextStyle(
                                          color: theme!.colorScheme.secondary,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18),
                                    )
                                  ],
                                ))),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InnerShadow(
                      shadows: [
                        BoxShadow(
                          color: theme!.colorScheme.secondary.withOpacity(.2),
                          blurRadius: 3.0,
                          spreadRadius: 0.0,
                          offset: const Offset(
                            0.0,
                            2.0,
                          ),
                        ),
                      ],
                      child: Container(
                          width: 116,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: theme!.colorScheme.secondaryContainer
                                    .withOpacity(0.6),
                              ),
                              child: tabBar(
                                children: {
                                  0: buildSegment(
                                      CupertinoIcons.music_note_2, 0),
                                  1: buildSegment(
                                      CupertinoIcons.list_bullet, 1),
                                },
                              ))),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: body(),
        ),
      ),
    );
  }

  Widget bottomToolbar() {
    return Container(
        decoration: BoxDecoration(
            color: theme!.colorScheme.secondaryContainer
                .withOpacity(isSubscribed ? 0.3 : 0.4),
            borderRadius: BorderRadius.circular(12)),
        height: 60,
        padding: const EdgeInsets.only(left: 16, right: 12),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "แพ็กเกจรายเดือน",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: theme!.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    "เข้าถึงประสบการณ์เต็มรูปแบบ",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: theme!.colorScheme.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                  )
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 8),
                width: 80,
                height: 36,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      isSubscribed = true;
                    });
                  },
                  color: theme!.colorScheme.surface,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(62.0),
                  ),
                  child: Text(
                    "สมัคร",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: theme!.colorScheme.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 18),
                  ),
                ))
          ],
        ));
  }

  Widget body() {
    return BlocBuilder<ControllerCubit, ControllerState>(
        builder: (BuildContext context, ControllerState state) {
      if (state is ControllerMediaState) {
        return TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [playerWidget(state), playlistWidget(state)],
        );
      } else {
        return Container();
      }
    });
  }

  Widget playerWidget(ControllerMediaState state) {
    double width = MediaQuery.of(context).size.width;

    bool isPlaying = state is ControllerPlayingState;

    return StreamBuilder<SequenceState?>(
      stream: state.player.sequenceStateStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data?.sequence.isEmpty ?? true) {
          return const SizedBox();
        }
        final metadata = data!.currentSource!.tag as MediaItem;
        return Column(
          children: [
            Container(
              width: width,
              height: width - 28,
              padding: const EdgeInsets.only(bottom: 28, top: 0),
              //color: Colors.red,
              child: Center(
                  child: AnimatedContainer(
                width: width - (isPlaying ? 60 : 120),
                height: width - (isPlaying ? 60 : 120),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(isPlaying ? 16 : 24),
                  boxShadow: [
                    BoxShadow(
                        color: theme!.colorScheme.secondary.withOpacity(0.3),
                        blurRadius: isPlaying ? 24 : 10,
                        offset: Offset(0, isPlaying ? 16 : 2),
                        spreadRadius: isPlaying ? 4 : 2),
                  ],
                ),
                duration: const Duration(milliseconds: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    metadata.artUri.toString(),
                    width: width - (isPlaying ? 60 : 120),
                    height: width - (isPlaying ? 60 : 120),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
            ),
            SizedBox(
                width: width - 60,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metadata.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: theme!.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            metadata.album ?? "ไม่ระบุ",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: theme!.colorScheme.primary,
                                fontWeight: FontWeight.normal,
                                fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            Container(
              height: 10,
            ),
            StreamBuilder<PositionData>(
              stream: Rx.combineLatest3<Duration, Duration, Duration?,
                      PositionData>(
                  state.player.positionStream,
                  state.player.bufferedPositionStream,
                  state.player.durationStream,
                  (position, bufferedPosition, duration) => PositionData(
                      position, bufferedPosition, duration ?? Duration.zero)),
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return musicProgressBar(
                    context: context,
                    theme: theme,
                    width: width,
                    total: positionData?.duration ?? Duration.zero,
                    progress: positionData?.position ?? Duration.zero,
                    buffer: positionData?.bufferedPosition ?? Duration.zero,
                    onChanged: (Duration newPosition) {
                      state.player.seek(newPosition);
                    });
              },
            ),
            Container(
              height: 1,
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  loopButton(state),
                  Container(
                    width: 6,
                  ),
                  previousButton(state),
                  Container(
                    width: 10,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: state.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;

                      isPlaying = state is ControllerPlayingState;
                      isPlaying
                          ? playAnimationController.forward()
                          : playAnimationController.reverse();

                      return Container(
                        height: 80,
                        width: 80,
                        padding: const EdgeInsets.all(4),
                        child: MaterialButton(
                          onPressed: () {
                            _playPauseOnPressed(state);
                          },
                          color: isPlaying
                              ? theme!.colorScheme.primary
                              : theme!.colorScheme.onPrimary,
                          elevation: isPlaying ? 4 : 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(62.0),
                          ),
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: playAnimation,
                            size: 38.0,
                            color: isPlaying
                                ? theme!.colorScheme.onSecondary
                                : theme!.colorScheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 10,
                  ),
                  forwardButton(state),
                  Container(
                    width: 6,
                  ),
                  shuffleButton(state),
                ]),
            Container(
              height: 8,
            ),
            isEnableVolumeControl
                ? Container(
                    width: width,
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            theme!.colorScheme.secondary.withOpacity(0.7),
                        inactiveTrackColor: Colors.black.withOpacity(0.15),
                        trackShape: const RoundedRectSliderTrackShape(),
                        trackHeight: 2.0,
                        tickMarkShape:
                            const RoundSliderTickMarkShape(tickMarkRadius: 1.2),
                        activeTickMarkColor: theme!.colorScheme.surface,
                        inactiveTickMarkColor: Colors.black.withOpacity(0.15),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0,
                            elevation: 6,
                            pressedElevation: 6),
                        overlayColor: Colors.transparent,
                        //overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                CupertinoIcons.volume_mute,
                                color: theme!.colorScheme.secondary,
                              ),
                              onPressed: () {
                                volumeController.muteVolume();
                              },
                            ),
                          ),
                          Container(
                              width: width - (40 * 2) - (28 * 2),
                              child: Slider(
                                value: volume,
                                min: 0,
                                max: 1,
                                divisions: 6,
                                onChanged: (double value) {
                                  volume = value;
                                  volumeController.setVolume(value);
                                  setState(() {});
                                },
                              )),
                          Container(
                            width: 40,
                            child: IconButton(
                              icon: Icon(CupertinoIcons.volume_up,
                                  color: theme!.colorScheme.secondary),
                              onPressed: () {
                                volumeController.maxVolume();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Widget playlistWidget(ControllerMediaState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Container(
            alignment: Alignment.bottomLeft,
            height: 46,
            padding: const EdgeInsets.only(bottom: 6),
            margin: const EdgeInsets.only(left: 28),
            child: Text(
              "เพลย์ลิสต์",
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: TextStyle(
                  color: theme!.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
          )),
          loopButton(state),
          Container(
            width: 10,
          ),
          shuffleButton(state),
          Container(
            width: 20,
          ),
        ]),
        Container(
          height: 1,
          color: theme!.colorScheme.primary.withOpacity(0.15),
          margin: const EdgeInsets.only(left: 28, right: 28),
        ),
        Expanded(
            child: StreamBuilder<SequenceState?>(
          stream: state.player.sequenceStateStream,
          builder: (context, snapshot) {
            final playState = snapshot.data;
            final sequence = playState?.sequence ?? [];

            return ReorderableListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              onReorder: (int oldIndex, int newIndex) {
                context.read<ControllerCubit>().move(
                    previousState: state,
                    oldIndex: oldIndex,
                    newIndex: newIndex);
              },
              children: [
                for (var i = 0; i < sequence.length; i++)
                  Container(
                    key: ValueKey(sequence[i]),
                    margin: (i != playState?.currentIndex)
                        ? const EdgeInsets.only(
                            left: 8, right: 8, bottom: 4, top: 4)
                        : const EdgeInsets.only(
                            left: 0, right: 0, bottom: 8, top: 4),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: i == playState?.currentIndex
                                ? theme!.colorScheme.primary.withOpacity(.2)
                                : Colors.transparent,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                            offset: const Offset(
                              0.0,
                              5.0,
                            ),
                          ),
                        ],
                        color: i == playState?.currentIndex
                            ? theme!.colorScheme.onSecondary.withOpacity(1.0)
                            : theme!.colorScheme.secondaryContainer
                                .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16)),
                    child: Dismissible(
                        key: ValueKey(sequence[i]),
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.redAccent,
                          ),
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        onDismissed: (dismissDirection) {
                          context
                              .read<ControllerCubit>()
                              .remove(previousState: state, index: i);
                        },
                        child: GestureDetector(
                          onTap: () {
                            context
                                .read<ControllerCubit>()
                                .play(previousState: state, index: i);
                          },
                          child: Container(
                              constraints: const BoxConstraints(minHeight: 80),
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 12, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 50,
                                    height: 50,
                                    color: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                              "${sequence[i].tag.artUri}",
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover),
                                          i == playState?.currentIndex
                                              ? BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 2.0, sigmaY: 2.0),
                                                  child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Image.asset(
                                                          "assets/ezgif.com-gif-maker-6.gif")),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${sequence[i].tag.title}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(
                                              color:
                                                  theme!.colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "${sequence[i].tag.album}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color:
                                                  (theme!.colorScheme.secondary)
                                                      .withOpacity(0.8),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        )
                        /*child: Material(
                        color: i == state!.currentIndex
                            ? Colors.grey.shade300
                            : null,
                        child: ListTile(
                          title: Text(sequence[i].tag.title as String),
                          onTap: () {
                            player.seek(Duration.zero, index: i);
                          },
                        ),
                      ),*/
                        ),
                  )
              ],
            );
          },
        ))
      ],
    );
  }

  Widget shuffleButton(ControllerMediaState state) {
    return StreamBuilder<bool>(
      stream: state.player.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final shuffleModeEnabled = snapshot.data ?? false;
        return Container(
            height: 34,
            width: 34,
            child: IconButton(
              padding: const EdgeInsets.all(6),
              onPressed: () async {
                context
                    .read<ControllerCubit>()
                    .shuffle(!shuffleModeEnabled, previousState: state);
              },
              icon: Icon(
                CupertinoIcons.shuffle,
                size: 22,
                color: shuffleModeEnabled
                    ? Colors.orange
                    : theme!.colorScheme.secondary,
              ),
            ));
      },
    );
  }

  Widget loopButton(ControllerMediaState state) {
    return StreamBuilder<LoopMode>(
      stream: state.player.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        List<Icon> icons = [
          Icon(
            CupertinoIcons.repeat,
            size: 22,
            color: theme!.colorScheme.secondary,
          ),
          const Icon(
            CupertinoIcons.repeat,
            size: 22,
            color: Colors.orange,
          ),
          const Icon(
            CupertinoIcons.repeat_1,
            size: 22,
            color: Colors.orange,
          ),
        ];
        const cycleModes = [
          LoopMode.off,
          LoopMode.all,
          LoopMode.one,
        ];
        final index = cycleModes.indexOf(loopMode);
        return Container(
          height: 34,
          width: 34,

          child: IconButton(
            splashColor: Colors.transparent,
            padding: const EdgeInsets.all(6),
            onPressed: () {
              context
                  .read<ControllerCubit>()
                  .loop(loopMode, previousState: state);
            },
            icon: icons[index],
          ),
        );
      },
    );
  }

  Widget forwardButton(ControllerMediaState state) {
    return StreamBuilder<SequenceState?>(
      stream: state.player.sequenceStateStream,
      builder: (context, snapshot) => SizedBox(
          height: 60,
          width: 60,
          child: IconButton(
            splashColor: theme!.colorScheme.primary,
            padding: const EdgeInsets.all(12),
            onPressed: state.player.hasNext
                ? () {
                    context.read<ControllerCubit>().next(previousState: state);
                  }
                : null,
            icon: Icon(
              CupertinoIcons.forward_fill,
              size: 28,
              color: theme!.colorScheme.secondary
                  .withOpacity(state.player.hasNext ? 1.0 : 0.3),
            ),
          )),
    );
  }

  Widget previousButton(ControllerMediaState state) {
    return StreamBuilder<SequenceState?>(
      stream: state.player.sequenceStateStream,
      builder: (context, snapshot) => Container(
        height: 60,
        width: 60,
        child: IconButton(
          splashColor: theme!.colorScheme.primary,
          padding: const EdgeInsets.all(12),
          onPressed: state.player.hasPrevious
              ? () {
                  context
                      .read<ControllerCubit>()
                      .previous(previousState: state);
                }
              : null,
          icon: Icon(
            CupertinoIcons.backward_fill,
            size: 28,
            color: theme!.colorScheme.secondary
                .withOpacity(state.player.hasPrevious ? 1.0 : 0.3),
          ),
        ),
      ),
    );
  }

  Widget tabBar({required Map<int, Widget> children}) {
    return Container(
      height: 40,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 0, right: 0),
      padding: const EdgeInsets.all(0),
      child: CustomSlidingSegmentedControl<int>(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        //thumbColor: Colors.white,
        thumbDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme!.colorScheme.secondary.withOpacity(.2),
              blurRadius: 1.0,
              spreadRadius: 1.0,
              offset: const Offset(
                0.0,
                1.0,
              ),
            ),
          ],
        ),
        height: 40,
        innerPadding: const EdgeInsets.all(4),
        initialValue: 0,
        children: children,
        controller: _segmentedController,
        onValueChanged: (value) {
          setState(() {
            page = value;
            _segmentedController.value = value;
            _tabController.animateTo(page);
          });
        },
      ),
    );
  }

  Widget buildSegment(IconData icon, int number) {
    return Container(
        height: 40,
        padding: const EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 0),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: page == number
                ? theme!.colorScheme.secondary
                : theme!.colorScheme.secondary.withOpacity(0.7),
          ),
        ));
  }
}
