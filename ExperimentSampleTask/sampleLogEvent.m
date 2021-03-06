function logEvent(fileID, eventTime, state)
  fprintf(fileID, '%d, %f, %f, %d, %d, %s, %f, %d, %d, %d, %d, %s, %s, %d\n',...
    state.trialNr,...
    state.trialStart,...
    eventTime,...
    state.costsMoney,...
    state.costsSocial,...
    state.faceFilename,...
    state.recipChance,...
    state.choiceHighlight,...
    state.nGood,...
    state.nBad,...
    state.nClosed,...
    state.cursorX,...
    state.cursorY,...
    state.sampleOutcome);
end