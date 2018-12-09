//
//  main.m
//  say++
//
//  Created by Mark on 07/12/2018.
//  Copyright © 2018 Mark All rights reserved.
//

// pbas - The baseline pitch command changes the current speech pitch for the speech channel to the specified real value. If the pitch value is preceded by the + or - character, the speech pitch is adjusted relative to its current value. Baseline pitch values are always positive numbers in the range of 1.000 to 127.000.

// pmod - The pitch modulation command changes the modulation range for the speech channel, based on the specified modulation-depth real value.

// rate - The speech rate command sets the speech rate on the speech channel to the specified real value. Speech rates fall in the range 0.000 to 65535.999, which translates into a range of 50 to 500 words per minute. If the rate is preceded by a + or - character, the speech rate is increased or decreased relative to its current value.

// slnc - The silence command causes the synthesizer to generate silence for the specified number of milliseconds. You might want to insert extra silence between two sentences to allow listeners to fully absorb the meaning of the first one. Note that the precise timing of the silence will vary among synthesizers.

// volm - The speech volume command sets the speech volume on the current speech channel to the specified real value. If the volume value is preceded by a + or - character, the speech volume is increased or decreased relative to its current value.

// emph - The emphasis command causes the synthesizer to speak the next word with greater or less emphasis than it is currently using. The + parameter increases emphasis and the - parameter decreases emphasis. For example, to emphasize the word “not” in the following phrase, use the emph command as follows: Do [[emph +]] not [[emph -]] over tighten the screw.


#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

// -f file
// -v voice

NSString* testPhrase = @"[[pmod 10; rate 80; pbas 1]]sigh [[slnc 400; rate 200; pbas 1; emph +]]lent [[rate 80; pbas 35]]night[[slnc 750]] \
[[pmod 10; rate 80; pbas 1]]hoe [[slnc 400; rate 200; pbas 1; emph +]]lee [[rate 80; pbas 35]]night[[slnc 500]]";

void startSinging(NSSpeechSynthesizer* ns, NSString* voiceID, NSString* song)
{
    [ns setVoice:voiceID];
    [ns startSpeakingString:song];
}

int main(int argc, const char* argv[]) {
    @autoreleasepool
    {
        NSString* filePath = nil;
        NSString* defaultSinger = @"com.apple.speech.synthesis.voice.Alex";
        NSString* voice = nil;
        
        // handle command line args
        int opt;
        while((opt = getopt(argc, argv, "v:f:h:?:")) != -1)
        {
            switch(opt)
            {
                case 'h':
                case '?':
                    NSLog(@"Usage: say++ [-v voice] [-f input file]");
                    break;
                case 'v':
                    voice = [NSString stringWithUTF8String:optarg];
                    break;
                case 'f':
                    NSLog(@"using file: %s", optarg);
                    // read the contents into an NSString
                    NSString* argString = [NSString stringWithUTF8String:optarg];
                    filePath = [[NSString alloc]initWithContentsOfFile:argString];
                    if(filePath)
                    {
                        NSLog(@"using file: %s", optarg);
                    }
                    else
                    {
                        NSLog(@"Nope, I can't find %@", argString);
                    }
                    break;
            }
        }
        
        // select the correct voice
        voice = defaultSinger;
        NSArray* voiceArray = [NSSpeechSynthesizer availableVoices];
        bool found = false;
        for(int i=0; i< [voiceArray count]; i++)
        {
            const char* currentVoice = [[voiceArray objectAtIndex:i] UTF8String];
            if(strcasestr(currentVoice, [voice UTF8String]))
            {
                found = true;
                voice = [voiceArray objectAtIndex:i];
                break;
            }
        }
        
        if(!found)
        {
            NSLog(@"Couldn't find %s, so using default singer", [voice UTF8String]);
        }

        NSSpeechSynthesizer* ns = [[NSSpeechSynthesizer alloc] initWithVoice:voice];
        
        // com.apple.speech.synthesis.voice.kanya
        if(!filePath)
        {
            filePath = testPhrase;
        }
        startSinging(ns, voice, filePath);
        sleep(1);
        // wait for the singer to finsih before quitting
        while([ns isSpeaking])
        {
            sleep(1);
        }

    }
    return 0;
}
