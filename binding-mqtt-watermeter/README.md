<h3>My EPS32-CAM setup</h3>

I would like to share some thoughts about my “implementation.”

I was also looking to integrate my water meter into openHAB, since I had already connected my electricity meters. I happened to come across the “AI on the Edge” solution. Since MQTT is already integrated into my openHAB environment, this was a good approach for me. The total cost for “AI on the Edge” is also quite reasonable at around €35.

I used the latest version. The description on the internet does not always correspond 1:1 to the version, but that’s manageable. You can get started right away here…
https://jomjol.github.io/AI-on-the-edge-device-docs/Reference-Image/

The following points were important:
a) The camera ring must be freed from the adhesive so that the focus can be slightly improved by turning it clockwise.
https://jomjol.github.io/AI-on-the-edge-device-docs/Reference-Image/#focus
b) Since I don’t have a 3D printer, I took a pragmatic approach. I used a plastic bottle with a circumference comparable to that of the water meter. I cut it about 15 cm from the bottom using a utility knife. In the bottom (which is somewhat harder), I cut a vertical slot about 8 mm wide and 30 mm high. I then positioned the camera in this slot so that the flash would also shine through the opening. To avoid reflections, I lined the inside with black cardboard. Then I taped it together with duct tape and attached it to the top of the water meter using two small strips of duct tape.
c) Set two markers
https://jomjol.github.io/AI-on-the-edge-device-docs/Alignment/#define-two-reference-images
d) Set ROI – The frame must be chosen large enough.
https://jomjol.github.io/AI-on-the-edge-device-docs/ROI-Configuration/#how-to-setup-the-digit-rois-perfectlya
e) Mode selection. For my water meter, I selected the model dig-class100-0173-s2-q.tflite.
https://jomjol.github.io/AI-on-the-edge-device-docs/Choosing-the-Model/

In addition to my config.ini (which can be read via the interface), I also took a few pictures. I hope this makes it easier to follow. 