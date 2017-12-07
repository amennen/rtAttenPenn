# 2017.09.06 17:33:30 EDT
#Embedded file name: C:\Users\CNDS\Desktop\banda\FaceMatching\FaceMatching_BANDA.py
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.82.02), Sat Jan  9 02:16:18 2016
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""
from __future__ import division
from psychopy import visual, core, data, event, logging, gui
from psychopy.constants import *
import numpy as np
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os
import random
import itertools
from itertools import groupby
import os
import csv
configFile = os.path.abspath(os.path.join(os.path.abspath(__file__), '../..'))
configFile = os.path.join(configFile, 'config.csv')
if os.path.exists(configFile):
    with open(configFile, 'rb') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
        for row in spamreader:
            if row[0] == 'output':
                output = row[1]

else:
    output = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..', 'amennen'))
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)
expName = 'Resting'
expInfo = {}
dlg1 = gui.Dlg(title='Participant ID')
dlg1.addField('Participant')
dlg1.addField('Mode', choices=['Scanner', 'Practice'])
dlg1.addField('Day', choices=['A', 'B', 'C'])
dlg1.addField('Run', choices=['1', '2', '3', '4', '5', '6','7', '8', '9', '10', '11', '12', '13', '14', '15' ])
dlg1.show()
if dlg1.OK:
    expInfo['participant'] = dlg1.data[0]
    expInfo['runMode'] = dlg1.data[1]
    expInfo['session'] = dlg1.data[2]
    expInfo['run'] = dlg1.data[3]
    RunMode = expInfo['runMode']
else:
    core.quit()
expName = 'FaceMatching'
expInfo['expName'] = expName
expInfo['date'] = data.getDateStr()
filename = output + os.sep + expInfo['participant'] + os.sep + '%s_%s_%s_%s_%s_%s' % (expInfo['participant'],
 expInfo['runMode'],
 expInfo['session'],
 expInfo['run'],
 expInfo['expName'],
 expInfo['date'])
if expInfo['runMode'] == 'Scanner':
    runs = ['A', 'B']
else:
    runs = ['Practice']
thisExp = data.ExperimentHandler(name=expName, version='', extraInfo=expInfo, runtimeInfo=None, originPath=None, savePickle=True, saveWideText=True, dataFileName=filename)
logFile = logging.LogFile(filename + '.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)
endExpNow = False
win = visual.Window(size=(800, 600), fullscr=True, screen=1, allowGUI=False, allowStencil=False, monitor='testMonitor', color=[0, 0, 0], colorSpace='rgb', blendMode='avg', useFBO=True)
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 0.016666666666666666
happy_1Clock = core.Clock()
top = visual.ImageStim(win=win, name='top', image='sin', mask=None, ori=0, pos=[0, 0.4], size=[0.25, 0.5], color=[1, 1, 1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=0.0)
left = visual.ImageStim(win=win, name='left', image='sin', mask=None, ori=0, pos=[-0.3, -0.2], size=[0.25, 0.5], color=[1, 1, 1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-1.0)
right = visual.ImageStim(win=win, name='right', image='sin', mask=None, ori=0, pos=[0.3, -0.2], size=[0.25, 0.5], color=[1, 1, 1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-2.0)
fixationClock = core.Clock()
fixation_text = visual.TextStim(win=win, ori=0, name='fixation_text', text=u'+', font=u'Arial', pos=[0, 0], height=0.15, wrapWidth=None, color=u'white', colorSpace='rgb', opacity=1, depth=0.0)
globalClock = core.Clock()
routineTimer = core.CountdownTimer()
instructions_test = visual.TextStim(win=win, ori=0, name='instructions_test', text=u'Instructions:\n\nFind which bottom picture matches the top one. Pictures can be faces, fruits, or vegetables.\n\nPress any button to continue.', font=u'Arial', pos=[0, 0], height=0.1, wrapWidth=1.5, color=u'white', colorSpace='rgb', opacity=1, depth=0.0)
instructions_test.draw()
win.flip()
event.waitKeys(keyList=['0',
 '1',
 '2',
 '3',
 '4',
 '5',
 '6',
 '7',
 '8',
 '9',
 'space',
 'escape'])
instructions_text_pressI = visual.TextStim(win=win, ori=0, name='instructions_test', text=u'If the bottom left matches, press the index finger button. (press it now!)', font=u'Arial', pos=[0, 0], height=0.1, wrapWidth=1.5, color=u'white', colorSpace='rgb', opacity=1, depth=0.0)
instructions_text_pressI.draw()
win.flip()
event.waitKeys(keyList=['1', '9'])
instructions_text_pressM = visual.TextStim(win=win, ori=0, name='instructions_test', text=u'If the bottom right matches, press the middle finger button. (press it now!)', font=u'Arial', pos=[0, 0], height=0.1, wrapWidth=1.5, color=u'white', colorSpace='rgb', opacity=1, depth=0.0)
instructions_text_pressM.draw()
win.flip()
event.waitKeys(keyList=['2', '8'])
for r in runs:
    expInfo['run'] = r
    conditionFile = 'face_matching_stimuli_' + r + '.csv'
    thisExp.nextEntry()
    routineTimer.reset()
    msgExpter = visual.TextStim(win, text='Waiting for the experimenter.', pos=(0, 0), colorSpace='rgb', color=1, height=0.1, wrapWidth=1.5, depth=0.01)
    msgExpter.draw()
    msgExpter.draw()
    win.flip()
    event.waitKeys(keyList=['q'])
    msgMachine = visual.TextStim(win, text='Waiting for the scanner.', pos=(0, 0), colorSpace='rgb', color=1, height=0.1, wrapWidth=1.5, depth=0.01)
    msgMachine.draw()
    msgMachine.draw()
    win.flip()
    event.waitKeys(keyList=['=', 'equal'])
    routineTimer.reset()
    trials = data.TrialHandler(nReps=1, method='sequential', extraInfo=expInfo, originPath=None, trialList=data.importConditions(conditionFile), seed=None, name='trials')
    thisExp.addLoop(trials)
    thisTrial = trials.trialList[0]
    if thisTrial != None:
        for paramName in thisTrial.keys():
            exec paramName + '= thisTrial.' + paramName

    for thisTrial in trials:
        currentLoop = trials
        if thisTrial != None:
            for paramName in thisTrial.keys():
                exec paramName + '= thisTrial.' + paramName

        t = 0
        happy_1Clock.reset()
        frameN = -1
        routineTimer.add(3.0)
        top.setImage(top_image)
        left.setImage(left_image)
        right.setImage(right_image)
        key_resp_trial = event.BuilderKeyResponse()
        key_resp_trial.status = NOT_STARTED
        happy_1Components = []
        happy_1Components.append(top)
        happy_1Components.append(left)
        happy_1Components.append(right)
        happy_1Components.append(key_resp_trial)
        for thisComponent in happy_1Components:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED

        if 'fixation' in top.image:
            print 'this roung is fixation', top.image
            t = 0
            fixationClock.reset()
            frameN = -1
            routineTimer.add(3.0)
            fixationComponents = []
            fixationComponents.append(fixation_text)
            for thisComponent in fixationComponents:
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED

            continueRoutine = True
            while continueRoutine and routineTimer.getTime() > 0:
                t = fixationClock.getTime()
                frameN = frameN + 1
                if t >= 0.0 and fixation_text.status == NOT_STARTED:
                    fixation_text.tStart = t
                    fixation_text.frameNStart = frameN
                    fixation_text.setAutoDraw(True)
                if fixation_text.status == STARTED and t >= 0.0 + (3 - win.monitorFramePeriod * 0.75):
                    fixation_text.setAutoDraw(False)
                if not continueRoutine:
                    break
                continueRoutine = False
                for thisComponent in fixationComponents:
                    if hasattr(thisComponent, 'status') and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break

                if endExpNow or event.getKeys(keyList=['escape']):
                    core.quit()
                if continueRoutine:
                    win.flip()

            for thisComponent in fixationComponents:
                if hasattr(thisComponent, 'setAutoDraw'):
                    thisComponent.setAutoDraw(False)

        else:
            print 'image ', top.image
            continueRoutine = True
            allPressedKeys = []
            allPressedKeysTime = []
            while continueRoutine and routineTimer.getTime() > 0:
                t = happy_1Clock.getTime()
                frameN = frameN + 1
                if t >= 0 and top.status == NOT_STARTED:
                    top.tStart = t
                    top.frameNStart = frameN
                    top.setAutoDraw(True)
                if top.status == STARTED and t >= 0 + (3 - win.monitorFramePeriod * 0.75):
                    top.setAutoDraw(False)
                if t >= 0 and left.status == NOT_STARTED:
                    left.tStart = t
                    left.frameNStart = frameN
                    left.setAutoDraw(True)
                if left.status == STARTED and t >= 0 + (3 - win.monitorFramePeriod * 0.75):
                    left.setAutoDraw(False)
                if t >= 0 and right.status == NOT_STARTED:
                    right.tStart = t
                    right.frameNStart = frameN
                    right.setAutoDraw(True)
                if right.status == STARTED and t >= 0 + (3 - win.monitorFramePeriod * 0.75):
                    right.setAutoDraw(False)
                if t >= 0.0 and key_resp_trial.status == NOT_STARTED:
                    key_resp_trial.tStart = t
                    key_resp_trial.frameNStart = frameN
                    key_resp_trial.status = STARTED
                    key_resp_trial.clock.reset()
                    event.clearEvents(eventType='keyboard')
                if key_resp_trial.status == STARTED and t >= 0.0 + (3 - win.monitorFramePeriod * 0.75):
                    key_resp_trial.status = STOPPED
                if key_resp_trial.status == STARTED:
                    theseKeys = event.getKeys(keyList=['1',
                     '2',
                     '8',
                     '9'])
                    if 'escape' in theseKeys:
                        endExpNow = True
                    if len(theseKeys) > 0:
                        key_resp_trial.keys = theseKeys[-1]
                        key_resp_trial.rt = key_resp_trial.clock.getTime()
                        if key_resp_trial.keys == str(int(corr_ans)) or key_resp_trial.keys == corr_ans or key_resp_trial.keys == str(int(corr_ans_Left)) or key_resp_trial.keys == corr_ans_Left:
                            key_resp_trial.corr = 1
                        else:
                            key_resp_trial.corr = 0
                        for k in theseKeys:
                            allPressedKeys.append(k)
                            allPressedKeysTime.append(key_resp_trial.clock.getTime())

                if not continueRoutine:
                    break
                continueRoutine = False
                for thisComponent in happy_1Components:
                    if hasattr(thisComponent, 'status') and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break

                if endExpNow or event.getKeys(keyList=['escape']):
                    core.quit()
                if continueRoutine:
                    win.flip()

            for thisComponent in happy_1Components:
                if hasattr(thisComponent, 'setAutoDraw'):
                    thisComponent.setAutoDraw(False)

            if key_resp_trial.keys in ['', [], None]:
                key_resp_trial.keys = None
                if str(corr_ans).lower() == 'none':
                    key_resp_trial.corr = 1
                else:
                    key_resp_trial.corr = 0
            trials.addData('key_resp_trial.keys', key_resp_trial.keys)
            trials.addData('key_resp_trial.corr', key_resp_trial.corr)
            if key_resp_trial.keys != None:
                trials.addData('key_resp_trial.rt', key_resp_trial.rt)
            trials.addData('allPressedKeys', str(allPressedKeys).replace(',', ':'))
            trials.addData('allPressedKeysTime', str(allPressedKeysTime).replace(',', ':'))
            thisExp.nextEntry()

    thisExp.nextEntry()

thanks_text = visual.TextStim(win=win, ori=0, name='thanks_text', text=u'Thanks!', font=u'Arial', pos=[0, 0], height=0.1, wrapWidth=None, color=u'white', colorSpace='rgb', opacity=1, depth=0.0)
thanks_text.draw()
win.flip()
event.waitKeys(keyList=['0',
 '1',
 '2',
 '3',
 '4',
 '5',
 '6',
 '7',
 '8',
 '9',
 'space',
 'escape'])
win.close()
core.quit()
# decompiled 1 files: 1 okay, 0 failed, 0 verify failed
# 2017.09.06 17:33:31 EDT
