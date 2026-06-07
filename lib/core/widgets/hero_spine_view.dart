/// A live Spine 3.8 hero animation, embedded via the vendored web player.
///
/// Web-only: on web it renders an `<iframe>` hosting `/spine_viewer.html`,
/// which loads the hero's `.skel` + `.atlas` + textures from `/spines/<id>/`.
/// On any non-web target it degrades to an empty box (see the stub).
export 'hero_spine_view_stub.dart'
    if (dart.library.ui_web) 'hero_spine_view_web.dart';
