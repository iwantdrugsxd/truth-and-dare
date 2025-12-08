// Questions data - imported from Flutter app
const questions = require('../questions.json');

module.exports = {
  getRandomQuestion: () => {
    const allQuestions = questions.questions || [];
    if (allQuestions.length === 0) {
      return {
        id: 1,
        category: "Spicy",
        question: "What's the wildest thing you've ever done?",
        answerType: "story"
      };
    }
    const randomIndex = Math.floor(Math.random() * allQuestions.length);
    return allQuestions[randomIndex];
  },
  
  getQuestionById: (id) => {
    const allQuestions = questions.questions || [];
    return allQuestions.find(q => q.id === id);
  }
};

