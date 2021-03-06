library webapp_base_ui_angular.mm_uia_accordion;

import 'dart:html' as html;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart' as utils;

import 'package:angular_accordion/angular/decorators/collapse.dart';

// It's just a sample!!!!
import 'package:angular_accordion/model.dart';

import 'package:logging/logging.dart' show Logger;

part 'mm_uia_accordion_group.dart';

class AccordionModule extends Module {
    AccordionModule() {
        install(new CollapseModule());
        install(new MyBindHtmlModule());

        bind(AccordionComponent);
        bind(AccordionHeadingComponent);
        bind(AccordionToolbarComponent);
        bind(AccordionGroupComponent);

        bind(AccordionConfig, toValue: new AccordionConfig());
    }
}

@Injectable()
class AccordionConfig {
    bool closeOthers = true;
}

// @formatter:off
@Component(
    selector: 'accordion',
    visibility: Visibility.CHILDREN,
    templateUrl: 'packages/angular_accordion/mm_uia_accordion/mm_uia_accordion.html',
    useShadowDom: false)
// @formatter:on
class AccordionComponent {
    final _logger = new Logger('webapp_base_ui_angular.mm_uia_accordion.AccordionComponent');

    @NgTwoWay('close-others')
    bool isCloseOthers;

    final AccordionConfig _config;

    /// This array keeps track of the accordion groups
    List<AccordionGroupComponent> groups = [];

    AccordionComponent(this._config) {
        _logger.fine('AccordionComponent');
    }

    /// Ensure that all the groups in this accordion are closed, unless close-others explicitly says not to
    void closeOthers(AccordionGroupComponent openGroup) {
        isCloseOthers = isCloseOthers != null ? isCloseOthers : _config.closeOthers;
        if (isCloseOthers) {
            groups.forEach((e) {
                if (e != openGroup) {
                    e.isOpen = false;
                }
            });
        }
    }

    /// This is called from the accordion-group directive to add itself to the accordion
    void addGroup(AccordionGroupComponent groupScope) {
        groups.add(groupScope);
    }

    /// This is called from the accordion-group directive when to remove itself
    void removeGroup(AccordionGroupComponent groupScope) {
        groups.remove(groupScope);
    }
}


@Decorator(selector: '[my-bind-html]',map: const {'my-bind-html': '@html'})
class MyBindHtmlDirective {
    final _logger = new Logger('webapp_base_ui_angular.mm_uia_accordion.MyBindHtmlDirective');

    final html.Element element;
    final Scope scope;
    final ViewFactoryCache viewFactoryCache;
    final DirectiveInjector directiveInjector;
    final DirectiveMap directives;

    View _view;
    Scope _childScope;

    MyBindHtmlDirective(this.element, this.scope, this.viewFactoryCache, this.directiveInjector, this.directives);

    //@NgOneWay('my-bind-html')
    set html(value) {
        _logger.info("Scope: $scope");

        _cleanUp();

        if (value != null && value != '') {
            _updateContent(viewFactoryCache.fromHtml(value, directives));
        }
    }

    _cleanUp() {
        if (_view == null) return;
        _view.nodes.forEach((node) => node.remove);
        _childScope.destroy();
        _childScope = null;
        element.innerHtml = '';
        _view = null;
    }

    _updateContent(final ViewFactory viewFactory) {
        // create a new scope
        _childScope = scope.createProtoChild();
        _view = viewFactory(_childScope, directiveInjector);
        _view.nodes.forEach((node) => element.append(node));
    }
}