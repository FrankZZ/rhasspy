<template>
    <div class="container">
        <form class="form" v-on:submit.prevent="saveSettings">
            <div class="form-group">
                <div class="form-row text-muted pl-1">
                    <p>
                        This is a simplified interface to edit your <a href="https://rhasspy.readthedocs.io/en/latest/profiles/">your Rhasspy profile</a>. If you want to access the JSON directly, see the Advanced tab.
                    </p>
                </div>
                <div class="form-row pl-1">
                    <p><strong>Restart required if changes are made</strong></p>
                </div>
            </div>

            <h2>{{ this.profile.name || this.profile.language }}</h2>

            <Overview :profile="profile" />

            <button class="btn btn-primary mt-3">Save Settings</button>
            <Rhasspy id="profile-rhasspy"
                     :profile="profile"
                     :defaults="defaults"
                     :profiles="profiles"
                     v-on:begin-async="$emit('begin-async')"
                     v-on:end-async="$emit('end-async')"
                     v-on:restart="$emit('restart')"
            />

            <HomeAssistant id="profile-handle" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <WakeWord id="profile-wake" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <VoiceDetection id="profile-command" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <SpeechRecognition id="profile-stt" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <IntentRecognition id="profile-intent" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <TextToSpeech id="profile-tts" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <AudioRecording id="profile-microphone"
                            :profile="profile"
                            v-on:begin-async="$emit('begin-async')"
                            v-on:end-async="$emit('end-async')"
                            v-on:alert="$emit('alert', $event)"
                            v-on:error="$emit('error', $event)" />
            <button class="btn btn-primary mt-3">Save Settings</button>

            <AudioPlaying id="profile-sounds" :profile="profile" />
            <button class="btn btn-primary mt-3">Save Settings</button>

        </form>
    </div> <!-- container -->
</template>

<script>
 import ProfileService from '@/services/ProfileService'

 import Overview from '@/components/profile/Overview'
 import Rhasspy from '@/components/profile/Rhasspy'
 import HomeAssistant from '@/components/profile/HomeAssistant'
 import WakeWord from '@/components/profile/WakeWord'
 import VoiceDetection from '@/components/profile/VoiceDetection'
 import SpeechRecognition from '@/components/profile/SpeechRecognition'
 import IntentRecognition from '@/components/profile/IntentRecognition'
 import AudioRecording from '@/components/profile/AudioRecording'
 import AudioPlaying from '@/components/profile/AudioPlaying'
 import TextToSpeech from '@/components/profile/TextToSpeech'

 export default {
     name: 'ProfileSettings',
     components: {
         Overview,
         HomeAssistant,
         Rhasspy,
         WakeWord,
         VoiceDetection,
         SpeechRecognition,
         IntentRecognition,
         AudioRecording,
         AudioPlaying,
         TextToSpeech
     },

     props: {
         profile : Object,
         profiles: Array,
         defaults: Object
     },

     methods: {
         saveSettings: function() {
             // POST to server
             this.$parent.beginAsync()
             ProfileService.updateDefaultSettings(this.defaults)
                 .then(() => {
                     ProfileService.updateProfileSettings(this.profile)
                                   .then(request => this.$parent.alert(request.data, 'success'))
                                   .then(() => {
                                       this.$parent.endAsync()
                                   })
                                   .catch(err => this.$parent.error(err))
                 })
                 .catch(err => this.$parent.error(err))
         },
     }
 }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
