class RevealMeQuestion {
  final int id;
  final String category;
  final String question;
  final String answerType;

  RevealMeQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.answerType,
  });

  static List<RevealMeQuestion> get allQuestions {
    return [
      // Relationships
      RevealMeQuestion(id: 1, category: "Relationships", question: "Who was the last person you caught feelings for even though you knew it would end badly?", answerType: "story"),
      RevealMeQuestion(id: 2, category: "Relationships", question: "Name a person you should have never dated but did anyway — and why.", answerType: "story"),
      RevealMeQuestion(id: 3, category: "Relationships", question: "Tell the story of the most chaotic argument you've ever had with a partner.", answerType: "story"),
      RevealMeQuestion(id: 4, category: "Relationships", question: "Who is the biggest 'what if' in your life? Explain.", answerType: "story"),
      RevealMeQuestion(id: 5, category: "Relationships", question: "Describe the moment you realized a relationship was over.", answerType: "story"),
      RevealMeQuestion(id: 6, category: "Relationships", question: "Name the most emotionally confusing person you've ever dealt with — what made them confusing?", answerType: "story"),
      RevealMeQuestion(id: 7, category: "Relationships", question: "Share a memory with someone you loved but couldn't be with.", answerType: "story"),
      RevealMeQuestion(id: 8, category: "Relationships", question: "Who is one person you still think about sometimes, even though you shouldn't?", answerType: "story"),
      RevealMeQuestion(id: 9, category: "Relationships", question: "Describe the most romantic thing someone has ever done for you.", answerType: "story"),
      RevealMeQuestion(id: 10, category: "Relationships", question: "Describe the most romantic thing you've done for someone — did they deserve it?", answerType: "story"),
      
      // Spicy
      RevealMeQuestion(id: 11, category: "Spicy", question: "Describe the most unforgettable kiss you've ever had — with who, and what made it unforgettable?", answerType: "story"),
      RevealMeQuestion(id: 12, category: "Spicy", question: "Tell the wildest romantic/physical experience you've had on a trip.", answerType: "story"),
      RevealMeQuestion(id: 13, category: "Spicy", question: "Who was your biggest unexpected attraction — someone you never thought you'd like?", answerType: "story"),
      RevealMeQuestion(id: 14, category: "Spicy", question: "Share a moment where chemistry took over and surprised you.", answerType: "story"),
      RevealMeQuestion(id: 15, category: "Spicy", question: "Describe your most chaotic almost-situation with someone.", answerType: "story"),
      RevealMeQuestion(id: 16, category: "Spicy", question: "Name the person who gives you the most intrusive thoughts — and why.", answerType: "story"),
      RevealMeQuestion(id: 17, category: "Spicy", question: "Describe the most impulsive thing you've done because of attraction.", answerType: "story"),
      RevealMeQuestion(id: 18, category: "Spicy", question: "Tell the story of the most tension-filled moment you've ever experienced with someone.", answerType: "story"),
      RevealMeQuestion(id: 19, category: "Spicy", question: "Who is someone you would never admit you find attractive, but secretly do?", answerType: "name"),
      RevealMeQuestion(id: 20, category: "Spicy", question: "Describe a moment when you almost crossed a line but stopped — what held you back?", answerType: "story"),
      
      // Confessions
      RevealMeQuestion(id: 21, category: "Confessions", question: "What is a secret crush you've had that no one in the room knows about?", answerType: "name"),
      RevealMeQuestion(id: 22, category: "Confessions", question: "Tell a lie you told in a past relationship that still haunts you.", answerType: "story"),
      RevealMeQuestion(id: 23, category: "Confessions", question: "Share the most reckless decision you've made because of emotions.", answerType: "story"),
      RevealMeQuestion(id: 24, category: "Confessions", question: "Who is someone you misjudged badly — and what changed your opinion?", answerType: "story"),
      RevealMeQuestion(id: 25, category: "Confessions", question: "Describe a moment you knew you were the villain in someone's story.", answerType: "story"),
      
      // Opinion
      RevealMeQuestion(id: 26, category: "Opinion", question: "What is a relationship opinion you have that most people would disagree with?", answerType: "explanation"),
      RevealMeQuestion(id: 27, category: "Opinion", question: "Which friend has the most toxic dating habits — and what makes them toxic?", answerType: "story"),
      RevealMeQuestion(id: 28, category: "Opinion", question: "Name a thing people find romantic that you actually find cringey.", answerType: "explanation"),
      RevealMeQuestion(id: 29, category: "Opinion", question: "What is a love lesson you learned the hard way?", answerType: "story"),
      RevealMeQuestion(id: 30, category: "Opinion", question: "Share an unpopular opinion you have about attraction.", answerType: "explanation"),
      
      // Friendship
      RevealMeQuestion(id: 31, category: "Friendship", question: "Tell the most dramatic fight you've ever had with a friend.", answerType: "story"),
      RevealMeQuestion(id: 32, category: "Friendship", question: "Which friend brings out your chaotic side the most — and how?", answerType: "story"),
      RevealMeQuestion(id: 33, category: "Friendship", question: "Describe a moment when a friend betrayed your trust.", answerType: "story"),
      RevealMeQuestion(id: 34, category: "Friendship", question: "Which friend has the most influence over your decisions?", answerType: "name"),
      RevealMeQuestion(id: 35, category: "Friendship", question: "What's the wildest memory you have with the group?", answerType: "story"),
      
      // Emotional
      RevealMeQuestion(id: 36, category: "Emotional", question: "Describe the most vulnerable moment you've had in front of someone.", answerType: "story"),
      RevealMeQuestion(id: 37, category: "Emotional", question: "Who is someone you'll always care about, even if you're not in contact anymore?", answerType: "name"),
      RevealMeQuestion(id: 38, category: "Emotional", question: "Share a moment when someone made you feel truly seen.", answerType: "story"),
      RevealMeQuestion(id: 39, category: "Emotional", question: "What is a heartbreak story that shaped who you are today?", answerType: "story"),
      RevealMeQuestion(id: 40, category: "Emotional", question: "Describe someone you miss but would never admit it to.", answerType: "name"),
      
      // More Spicy
      RevealMeQuestion(id: 41, category: "Spicy", question: "Describe the moment you felt the strongest physical chemistry with someone — what triggered it?", answerType: "story"),
      RevealMeQuestion(id: 42, category: "Spicy", question: "Who is someone you had instant attraction to the second you saw them?", answerType: "name"),
      RevealMeQuestion(id: 43, category: "Spicy", question: "Tell the most daring compliment someone has given you — the one you still think about.", answerType: "story"),
      RevealMeQuestion(id: 44, category: "Spicy", question: "What's the most dangerously flirtatious thing you've ever done?", answerType: "story"),
      RevealMeQuestion(id: 45, category: "Spicy", question: "Who is someone you flirted with even though you knew you shouldn't?", answerType: "name"),
      RevealMeQuestion(id: 46, category: "Spicy", question: "Describe a moment where a small touch changed the entire energy.", answerType: "story"),
      RevealMeQuestion(id: 47, category: "Spicy", question: "What's the boldest DM you've ever received — or sent?", answerType: "story"),
      RevealMeQuestion(id: 48, category: "Spicy", question: "Tell the story of the most electrifying eye contact moment you've ever experienced.", answerType: "story"),
      RevealMeQuestion(id: 49, category: "Spicy", question: "Who is one person you would break your 'no drama' rule for?", answerType: "name"),
      RevealMeQuestion(id: 50, category: "Spicy", question: "Describe the most impulsive, heat-of-the-moment decision you've made because of desire.", answerType: "story"),
      
      // More Confessions
      RevealMeQuestion(id: 51, category: "Confessions", question: "Tell a secret you've never admitted to a past partner.", answerType: "story"),
      RevealMeQuestion(id: 52, category: "Confessions", question: "What's the most embarrassing thing you did to impress someone you liked?", answerType: "story"),
      RevealMeQuestion(id: 53, category: "Confessions", question: "Which moment from your past relationship do you wish you could undo?", answerType: "story"),
      RevealMeQuestion(id: 54, category: "Confessions", question: "What's the biggest mixed signal you've ever given someone?", answerType: "story"),
      RevealMeQuestion(id: 55, category: "Confessions", question: "Name someone you used to like but now pretend you never did.", answerType: "name"),
      RevealMeQuestion(id: 56, category: "Confessions", question: "Tell the story of a moment you knew you deeply hurt someone.", answerType: "story"),
      RevealMeQuestion(id: 57, category: "Confessions", question: "What is the most manipulative thing you've ever done without realizing it?", answerType: "story"),
      RevealMeQuestion(id: 58, category: "Confessions", question: "Name a time you acted selfishly in a relationship and regretted it later.", answerType: "story"),
      RevealMeQuestion(id: 59, category: "Confessions", question: "Who is someone you led on unintentionally?", answerType: "name"),
      RevealMeQuestion(id: 60, category: "Confessions", question: "Tell a story from your romantic life that almost no one knows.", answerType: "story"),
      
      // Secrets
      RevealMeQuestion(id: 61, category: "Secrets", question: "What is the biggest secret you've kept from someone close to you?", answerType: "story"),
      RevealMeQuestion(id: 62, category: "Secrets", question: "Who is someone you've silently competed with — and why?", answerType: "name"),
      RevealMeQuestion(id: 63, category: "Secrets", question: "What is a fantasy or desire you've never shared with anyone?", answerType: "story"),
      RevealMeQuestion(id: 64, category: "Secrets", question: "Tell a time you pretended not to care but cared deeply.", answerType: "story"),
      RevealMeQuestion(id: 65, category: "Secrets", question: "Who is someone you keep around even though you shouldn't?", answerType: "name"),
      RevealMeQuestion(id: 66, category: "Secrets", question: "Describe a situation where you did the wrong thing for the right reason.", answerType: "story"),
      RevealMeQuestion(id: 67, category: "Secrets", question: "What's the darkest intrusive thought you've had about someone you know?", answerType: "story"),
      RevealMeQuestion(id: 68, category: "Secrets", question: "Name someone you pretend to like but secretly don't trust.", answerType: "name"),
      RevealMeQuestion(id: 69, category: "Secrets", question: "What is the biggest double life moment you've ever had?", answerType: "story"),
      RevealMeQuestion(id: 70, category: "Secrets", question: "Describe a moment when you knew you were hiding too much from someone.", answerType: "story"),
      
      // More Emotional
      RevealMeQuestion(id: 71, category: "Emotional", question: "Name a moment when you realized you were in love — or falling.", answerType: "story"),
      RevealMeQuestion(id: 72, category: "Emotional", question: "Who is someone you regret losing touch with?", answerType: "name"),
      RevealMeQuestion(id: 73, category: "Emotional", question: "Describe the most painful goodbye you've experienced.", answerType: "story"),
      RevealMeQuestion(id: 74, category: "Emotional", question: "Which person from your past still affects you emotionally?", answerType: "name"),
      RevealMeQuestion(id: 75, category: "Emotional", question: "Tell a moment when you realized someone cared more than you expected.", answerType: "story"),
      RevealMeQuestion(id: 76, category: "Emotional", question: "What memory hits you harder than you admit?", answerType: "story"),
      RevealMeQuestion(id: 77, category: "Emotional", question: "Describe a moment when someone's words stayed with you for years.", answerType: "story"),
      RevealMeQuestion(id: 78, category: "Emotional", question: "Who is someone who changed you without knowing it?", answerType: "name"),
      RevealMeQuestion(id: 79, category: "Emotional", question: "What's the most emotionally intense moment you've had recently?", answerType: "story"),
      RevealMeQuestion(id: 80, category: "Emotional", question: "What's a truth about your past you've never fully talked about?", answerType: "story"),
      
      // Party
      RevealMeQuestion(id: 81, category: "Party", question: "What's your wildest party story — the one you probably shouldn't share?", answerType: "story"),
      RevealMeQuestion(id: 82, category: "Party", question: "Who is the most unpredictable person you've ever partied with?", answerType: "name"),
      RevealMeQuestion(id: 83, category: "Party", question: "Describe the worst decision you've made at a party.", answerType: "story"),
      RevealMeQuestion(id: 84, category: "Party", question: "What's the funniest drunk moment you remember clearly?", answerType: "story"),
      RevealMeQuestion(id: 85, category: "Party", question: "Which friend becomes chaotic after two drinks?", answerType: "name"),
      RevealMeQuestion(id: 86, category: "Party", question: "Tell the story of a night out that went completely off-script.", answerType: "story"),
      RevealMeQuestion(id: 87, category: "Party", question: "What's the most embarrassing thing you've done at a club or bar?", answerType: "story"),
      RevealMeQuestion(id: 88, category: "Party", question: "Describe the most unexpected thing that happened during a party.", answerType: "story"),
      RevealMeQuestion(id: 89, category: "Party", question: "Who do you trust the least when you're drunk?", answerType: "name"),
      RevealMeQuestion(id: 90, category: "Party", question: "What's one party moment you wish you had on video?", answerType: "story"),
      
      // Attraction
      RevealMeQuestion(id: 91, category: "Attraction", question: "Who gave you the strongest first impression of attraction in your entire life?", answerType: "name"),
      RevealMeQuestion(id: 92, category: "Attraction", question: "Describe the most confusing crush you've ever had.", answerType: "story"),
      RevealMeQuestion(id: 93, category: "Attraction", question: "Who is the most magnetic person you've met — someone you couldn't ignore?", answerType: "name"),
      RevealMeQuestion(id: 94, category: "Attraction", question: "Tell the story of a crush that came out of nowhere.", answerType: "story"),
      RevealMeQuestion(id: 95, category: "Attraction", question: "Who is someone you were attracted to only after getting to know them?", answerType: "name"),
      RevealMeQuestion(id: 96, category: "Attraction", question: "What's the hardest you've ever fallen for someone you barely knew?", answerType: "story"),
      RevealMeQuestion(id: 97, category: "Attraction", question: "Who is your biggest almost-crush that never became something more?", answerType: "name"),
      RevealMeQuestion(id: 98, category: "Attraction", question: "Describe a moment when you felt genuine chemistry with someone unexpected.", answerType: "story"),
      RevealMeQuestion(id: 99, category: "Attraction", question: "Who is someone you were attracted to but now think 'I was delusional'?", answerType: "name"),
      RevealMeQuestion(id: 100, category: "Attraction", question: "Tell the story of your earliest serious crush — what made them special?", answerType: "story"),
      
      // Red Flags
      RevealMeQuestion(id: 101, category: "Red Flags", question: "What is your most dangerous red flag in relationships?", answerType: "explanation"),
      RevealMeQuestion(id: 102, category: "Red Flags", question: "Who brought out the most toxic version of you?", answerType: "name"),
      RevealMeQuestion(id: 103, category: "Red Flags", question: "Describe the moment you realized you were ignoring obvious red flags.", answerType: "story"),
      RevealMeQuestion(id: 104, category: "Red Flags", question: "What's the red flag you always fall for?", answerType: "explanation"),
      RevealMeQuestion(id: 105, category: "Red Flags", question: "Tell the most chaotic red flag moment you've ever lived through.", answerType: "story"),
      
      // Chaotic
      RevealMeQuestion(id: 106, category: "Chaotic", question: "What is the most reckless thing you've done because of emotions or attraction?", answerType: "story"),
      RevealMeQuestion(id: 107, category: "Chaotic", question: "Describe a moment where you completely lost control in a dramatic way.", answerType: "story"),
      RevealMeQuestion(id: 108, category: "Chaotic", question: "Which situation from your past feels like it belongs in a movie?", answerType: "story"),
      RevealMeQuestion(id: 109, category: "Chaotic", question: "Tell a story of the most unexpected consequence of something you did.", answerType: "story"),
      RevealMeQuestion(id: 110, category: "Chaotic", question: "Who did you have the most dramatic moment with — and what happened?", answerType: "story"),
      
      // More Opinion
      RevealMeQuestion(id: 111, category: "Opinion", question: "What is a belief you have about love that most people would find shocking?", answerType: "explanation"),
      RevealMeQuestion(id: 112, category: "Opinion", question: "Which friend's relationship choices do you secretly disagree with the most?", answerType: "name"),
      RevealMeQuestion(id: 113, category: "Opinion", question: "What is the biggest mistake people make when they fall in love?", answerType: "explanation"),
      RevealMeQuestion(id: 114, category: "Opinion", question: "What is one trait you think people overrate when choosing partners?", answerType: "explanation"),
      RevealMeQuestion(id: 115, category: "Opinion", question: "Share an unpopular dating opinion you strongly believe in.", answerType: "explanation"),
      
      // Truth
      RevealMeQuestion(id: 116, category: "Truth", question: "Tell the most uncomfortable truth about your personality that you usually avoid admitting.", answerType: "story"),
      RevealMeQuestion(id: 117, category: "Truth", question: "Who is someone you pretend to be over but absolutely aren't?", answerType: "name"),
      RevealMeQuestion(id: 118, category: "Truth", question: "Describe a moment you acted out of insecurity instead of confidence.", answerType: "story"),
      RevealMeQuestion(id: 119, category: "Truth", question: "What is a truth about your romantic habits that friends would be shocked to hear?", answerType: "story"),
      RevealMeQuestion(id: 120, category: "Truth", question: "What's the hardest truth you've had to accept about yourself?", answerType: "story"),
      
      // More Party
      RevealMeQuestion(id: 121, category: "Party", question: "Tell the story of the wildest night out you've ever had — the one that went completely off the rails.", answerType: "story"),
      RevealMeQuestion(id: 122, category: "Party", question: "Who is the most chaotic person you've ever gone drinking with — and what happened?", answerType: "name"),
      RevealMeQuestion(id: 123, category: "Party", question: "Describe the most questionable decision you made while drunk.", answerType: "story"),
      RevealMeQuestion(id: 124, category: "Party", question: "What is your funniest blackout or near-blackout memory?", answerType: "story"),
      RevealMeQuestion(id: 125, category: "Party", question: "Who is a person you should NEVER party with again — and why?", answerType: "name"),
      RevealMeQuestion(id: 126, category: "Party", question: "Tell a story about a party that ended very differently than it began.", answerType: "story"),
      RevealMeQuestion(id: 127, category: "Party", question: "Who is the person you become after three drinks?", answerType: "explanation"),
      RevealMeQuestion(id: 128, category: "Party", question: "Describe one party moment you wish you could erase from people's memories.", answerType: "story"),
      RevealMeQuestion(id: 129, category: "Party", question: "Tell the craziest dare you ever completed.", answerType: "story"),
      RevealMeQuestion(id: 130, category: "Party", question: "What is the most insane thing you've witnessed at a party?", answerType: "story"),
      
      // Forbidden
      RevealMeQuestion(id: 131, category: "Forbidden", question: "Who was your most forbidden crush — someone you absolutely shouldn't have liked?", answerType: "name"),
      RevealMeQuestion(id: 132, category: "Forbidden", question: "Describe the moment you realized you were attracted to someone unexpected.", answerType: "story"),
      RevealMeQuestion(id: 133, category: "Forbidden", question: "Name someone who gave you 'I shouldn't want this' vibes.", answerType: "name"),
      RevealMeQuestion(id: 134, category: "Forbidden", question: "Tell the story of a moment you were tempted to cross a major line.", answerType: "story"),
      RevealMeQuestion(id: 135, category: "Forbidden", question: "Who is someone you found attractive but never admitted to anyone?", answerType: "name"),
      RevealMeQuestion(id: 136, category: "Forbidden", question: "Describe a moment when you felt guilty for being attracted to someone.", answerType: "story"),
      RevealMeQuestion(id: 137, category: "Forbidden", question: "Who is the most 'wrong person' you've ever caught yourself thinking about?", answerType: "name"),
      RevealMeQuestion(id: 138, category: "Forbidden", question: "Tell a moment when someone's attention felt dangerously flattering.", answerType: "story"),
      RevealMeQuestion(id: 139, category: "Forbidden", question: "Name someone you would NEVER tell your friends you found attractive.", answerType: "name"),
      RevealMeQuestion(id: 140, category: "Forbidden", question: "Describe a moment when someone you shouldn't want made you blush.", answerType: "story"),
      
      // Past
      RevealMeQuestion(id: 141, category: "Past", question: "Which moment from your past feels like a movie scene whenever you think about it?", answerType: "story"),
      RevealMeQuestion(id: 142, category: "Past", question: "Name a person from your past who still crosses your mind occasionally.", answerType: "name"),
      RevealMeQuestion(id: 143, category: "Past", question: "Tell a story from your teenage or early adult years that still makes you laugh.", answerType: "story"),
      RevealMeQuestion(id: 144, category: "Past", question: "What is a moment from your past you're glad nobody recorded?", answerType: "story"),
      RevealMeQuestion(id: 145, category: "Past", question: "Who is a person you didn't appreciate then but appreciate now?", answerType: "name"),
      RevealMeQuestion(id: 146, category: "Past", question: "Describe a bold or risky decision from your past that surprisingly worked out.", answerType: "story"),
      RevealMeQuestion(id: 147, category: "Past", question: "Share the most embarrassing romantic fail from your past.", answerType: "story"),
      RevealMeQuestion(id: 148, category: "Past", question: "Who's the person you regret letting go of the most?", answerType: "name"),
      RevealMeQuestion(id: 149, category: "Past", question: "Describe a memory that shaped your entire view on love.", answerType: "story"),
      RevealMeQuestion(id: 150, category: "Past", question: "Who is someone you used to hate but ended up liking later?", answerType: "name"),
      
      // Dark
      RevealMeQuestion(id: 151, category: "Dark", question: "What is the most morally questionable thing you've done in the name of love or attraction?", answerType: "story"),
      RevealMeQuestion(id: 152, category: "Dark", question: "Who is someone you treated unfairly — and why?", answerType: "name"),
      RevealMeQuestion(id: 153, category: "Dark", question: "Tell a moment you acted in a way you're not proud of.", answerType: "story"),
      RevealMeQuestion(id: 154, category: "Dark", question: "What's a truth about your personality that feels 'dangerous' to admit?", answerType: "story"),
      RevealMeQuestion(id: 155, category: "Dark", question: "Who has seen the worst version of you — and what caused it?", answerType: "story"),
      RevealMeQuestion(id: 156, category: "Dark", question: "Describe the lowest emotional moment you've experienced.", answerType: "story"),
      RevealMeQuestion(id: 157, category: "Dark", question: "Who is someone you hurt unintentionally but feel guilty about?", answerType: "name"),
      RevealMeQuestion(id: 158, category: "Dark", question: "Tell the harshest truth you've learned about yourself.", answerType: "story"),
      RevealMeQuestion(id: 159, category: "Dark", question: "Name someone whose life you complicated more than you expected.", answerType: "name"),
      RevealMeQuestion(id: 160, category: "Dark", question: "What's a memory you hope nobody ever brings up again?", answerType: "story"),
      
      // More Chaotic
      RevealMeQuestion(id: 161, category: "Chaotic", question: "Tell the craziest misunderstanding you've ever been involved in.", answerType: "story"),
      RevealMeQuestion(id: 162, category: "Chaotic", question: "Who is the most dramatic person you've argued with?", answerType: "name"),
      RevealMeQuestion(id: 163, category: "Chaotic", question: "Describe the funniest—or messiest—accidental chaos you caused.", answerType: "story"),
      RevealMeQuestion(id: 164, category: "Chaotic", question: "Tell a moment where everything went wrong at once.", answerType: "story"),
      RevealMeQuestion(id: 165, category: "Chaotic", question: "Who do you always end up doing questionable things with?", answerType: "name"),
      RevealMeQuestion(id: 166, category: "Chaotic", question: "Describe a moment you almost got caught doing something you shouldn't have.", answerType: "story"),
      RevealMeQuestion(id: 167, category: "Chaotic", question: "Tell one plan that went horribly wrong but turned into a great story.", answerType: "story"),
      RevealMeQuestion(id: 168, category: "Chaotic", question: "Who is the most unpredictable person in your life right now?", answerType: "name"),
      RevealMeQuestion(id: 169, category: "Chaotic", question: "Describe an impulsive decision that still surprises you when you think about it.", answerType: "story"),
      RevealMeQuestion(id: 170, category: "Chaotic", question: "Tell the most dramatic \"caught in the moment\" situation you've experienced.", answerType: "story"),
      
      // Toxic
      RevealMeQuestion(id: 171, category: "Toxic", question: "What is the most toxic thing you've said or done during an argument?", answerType: "story"),
      RevealMeQuestion(id: 172, category: "Toxic", question: "Who brings out your toxic side the most?", answerType: "name"),
      RevealMeQuestion(id: 173, category: "Toxic", question: "Tell a moment when you realized YOU were the red flag.", answerType: "story"),
      RevealMeQuestion(id: 174, category: "Toxic", question: "What's the most manipulative thing someone has done to you — and how did you react?", answerType: "story"),
      RevealMeQuestion(id: 175, category: "Toxic", question: "What is the pettiest reason you've ended something with someone?", answerType: "story"),
      
      // WTF
      RevealMeQuestion(id: 176, category: "WTF", question: "What is the strangest situation you've ever found yourself in unexpectedly?", answerType: "story"),
      RevealMeQuestion(id: 177, category: "WTF", question: "Who was involved in the weirdest encounter you've ever had?", answerType: "name"),
      RevealMeQuestion(id: 178, category: "WTF", question: "Tell the most confusing moment you've experienced that still makes no sense.", answerType: "story"),
      RevealMeQuestion(id: 179, category: "WTF", question: "Describe a moment where you genuinely thought, 'How did I end up here?'", answerType: "story"),
      RevealMeQuestion(id: 180, category: "WTF", question: "What's the weirdest rumor you've heard about yourself?", answerType: "story"),
      
      // More Truth
      RevealMeQuestion(id: 181, category: "Truth", question: "What is a truth about your romantic life you've never said out loud before?", answerType: "story"),
      RevealMeQuestion(id: 182, category: "Truth", question: "Who is someone that changed your life more than they know?", answerType: "name"),
      RevealMeQuestion(id: 183, category: "Truth", question: "Describe a moment that made you rethink your entire approach to relationships.", answerType: "story"),
      RevealMeQuestion(id: 184, category: "Truth", question: "What is a recurring pattern in your love life that you wish you could break?", answerType: "story"),
      RevealMeQuestion(id: 185, category: "Truth", question: "What is something you want from love that you rarely admit?", answerType: "story"),
      
      // More Opinion
      RevealMeQuestion(id: 186, category: "Opinion", question: "What is an opinion about attraction or love that you think most people can't handle?", answerType: "explanation"),
      RevealMeQuestion(id: 187, category: "Opinion", question: "Who makes the worst relationship decisions among your friends?", answerType: "name"),
      RevealMeQuestion(id: 188, category: "Opinion", question: "What is one behavior you think is a massive turn-off that people pretend is attractive?", answerType: "explanation"),
      RevealMeQuestion(id: 189, category: "Opinion", question: "What's an opinion about intimacy you wish more people understood?", answerType: "explanation"),
      RevealMeQuestion(id: 190, category: "Opinion", question: "What is one dating rule you believe in that others would call toxic?", answerType: "explanation"),
      
      // Truth Bomb
      RevealMeQuestion(id: 191, category: "Truth Bomb", question: "Name someone you miss more than you admit.", answerType: "name"),
      RevealMeQuestion(id: 192, category: "Truth Bomb", question: "Describe the moment you realized you were falling for the wrong person.", answerType: "story"),
      RevealMeQuestion(id: 193, category: "Truth Bomb", question: "Who is someone you compare others to, even today?", answerType: "name"),
      RevealMeQuestion(id: 194, category: "Truth Bomb", question: "What is the most honest, vulnerable confession you could share right now?", answerType: "story"),
      RevealMeQuestion(id: 195, category: "Truth Bomb", question: "Who is someone you shouldn't want but do anyway?", answerType: "name"),
      RevealMeQuestion(id: 196, category: "Truth Bomb", question: "Tell the story of a moment that changed how you see yourself forever.", answerType: "story"),
      RevealMeQuestion(id: 197, category: "Truth Bomb", question: "Who is the person you think you will never fully get over?", answerType: "name"),
      RevealMeQuestion(id: 198, category: "Truth Bomb", question: "What's a truth you've avoided saying for years?", answerType: "story"),
      RevealMeQuestion(id: 199, category: "Truth Bomb", question: "Describe the moment someone disappointed you more than anyone else ever has.", answerType: "story"),
      RevealMeQuestion(id: 200, category: "Truth Bomb", question: "What is one feeling you still carry for someone that you wish you didn't?", answerType: "story"),
    ];
  }
}

