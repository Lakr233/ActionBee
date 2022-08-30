#!/usr/bin/env python3

import base64
import json
import os
from sys import stderr


# Write your code inside SolutionMain() function.


class PasteboardEvent:
    def __init__(self, focusAppID, focusAppName, pasteboardContent):
        self.focusAppID = focusAppID
        self.focusAppName = focusAppName
        self.pasteboardContent = pasteboardContent


class ActionBeeRecipe:
    def __init__(self, postAction, postContent, continueQueue):
        self.postAction = postAction
        self.postContent = postContent
        self.continueQueue = continueQueue

    def finalizeAndSend(self):
        message = json.dumps(self.__dict__)
        b64msg = base64.b64encode(message.encode('utf-8'))
        finalmsg = "\nActionBee-Result-Recipe://" + b64msg.decode('utf-8')
        print(finalmsg, file=stderr)
        exit(0)


def SolutionMain(event: PasteboardEvent) -> ActionBeeRecipe:
    print(event.focusAppID)
    print(event.focusAppName)
    print(event.pasteboardContent)

    return ActionBeeRecipe(
        postAction="none",  # none, overwrite, speak
        postContent=event.pasteboardContent,
        continueQueue=True
    )


if __name__ == '__main__':
    raw_event = base64.b64decode(
        os.environ['Communicator_Message']).decode('utf-8')
    json_object = json.loads(raw_event)
    event = PasteboardEvent(
        json_object['focusAppID'],
        json_object['focusAppName'],
        json_object['pasteboardContent']
    )
    recipe = SolutionMain(event)
    recipe.finalizeAndSend()
