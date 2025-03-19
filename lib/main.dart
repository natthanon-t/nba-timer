import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CountdownTimer(),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  static const int quarterDuration = 12 * 60;
  static const int timeoutDuration = 60;
  static const int halftimeDuration = 15 * 60;
  static const int restBetweenQuarters = 2 * 60;

  int timeLeft = quarterDuration;
  Timer? _timer;
  bool isRunning = false;
  bool isLoading = false;
  String latestGameInfo = "Loading latest games...";

  @override
  void initState() {
    super.initState();
    fetchLatestGameScores();
  }

  Future<void> fetchLatestGameScores() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List games = data['events'];

        String formattedGames = "Latest Games:\n";
        for (var game in games) {
          String team1 = game['competitions'][0]['competitors'][0]['team']['displayName'];
          String score1 = game['competitions'][0]['competitors'][0]['score'];
          String team2 = game['competitions'][0]['competitors'][1]['team']['displayName'];
          String score2 = game['competitions'][0]['competitors'][1]['score'];
          formattedGames += "$team1 $score1 - $score2 $team2\n";
        }

        setState(() {
          latestGameInfo = formattedGames;
        });
      } else {
        setState(() {
          latestGameInfo = "Failed to fetch latest games.";
        });
      }
    } catch (e) {
      setState(() {
        latestGameInfo = "Error loading data.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void startPauseTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          timer.cancel();
          isRunning = false;
        }
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void startTimeout() {
    _timer?.cancel();
    setState(() {
      timeLeft = timeoutDuration;
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        isRunning = false;
      }
    });
  }

  void startHalftime() {
    _timer?.cancel();
    setState(() {
      timeLeft = halftimeDuration;
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        isRunning = false;
      }
    });
  }

  void startRestPeriod() {
    _timer?.cancel();
    setState(() {
      timeLeft = restBetweenQuarters;
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        isRunning = false;
      }
    });
  }

  void resetQuarter() {
    _timer?.cancel();
    setState(() {
      timeLeft = quarterDuration;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NBA Countdown Timer"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/National_Basketball_Association_logo.svg/1920px-National_Basketball_Association_logo.svg.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text("Latest Games", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Text(latestGameInfo, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : fetchLatestGameScores,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: startPauseTimer, child: Text(isRunning ? "Pause" : "Start")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: startTimeout, child: const Text("Timeout")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: startHalftime, child: const Text("Halftime")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: startRestPeriod, child: const Text("Rest Between Quarters")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: resetQuarter, child: const Text("Reset")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
