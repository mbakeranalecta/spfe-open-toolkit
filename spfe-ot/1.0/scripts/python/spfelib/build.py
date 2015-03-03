__author__ = 'Mark Baker'
__copyright_ = 'Analecta Communications Inc. 2015'

import os
# XSLT only works with posixpaths, so use posixpath for values passed to XSLT
import posixpath
import shutil
from glob import glob
from . import util


def build_content_set(config):
    topic_set_id_list = [config.setting('topic-set-id', x) for x in config.iter_config_subset('content-set/topic-set')]
    object_set_id_list = [config.setting('object-set-id', x) for x in
                          config.iter_config_subset('content-set/object-set')]
    for topic_set_id in topic_set_id_list:
        _build_synthesis_stage(config=config, topic_set_id=topic_set_id)
    for object_set_id in object_set_id_list:
        _build_synthesis_stage(config=config, object_set_id=object_set_id)
    # FIXME: This is using step scripts to determine if stages should be run
    # and might be fragile if steps were added to a stage.
    for topic_set_id in topic_set_id_list:
        if any(step == "present" for (step, _) in config.build_scripts[topic_set_id]):
            _build_presentation_stage(config, topic_set_id)
    for topic_set_id in topic_set_id_list:
        if any(step == "format" for (step, _) in config.build_scripts[topic_set_id]):
            _build_formatting_stage(config, topic_set_id)
    for topic_set_id in topic_set_id_list:
        if any(step == "encode" for (step, _) in config.build_scripts[topic_set_id]):
            _build_encoding_stage(config, topic_set_id)


def _build_synthesis_stage(config, *, topic_set_id=None, object_set_id=None):
    assert topic_set_id is None or object_set_id is None
    assert topic_set_id is not None or object_set_id is not None
    set_id = topic_set_id if topic_set_id is not None else object_set_id
    set_type = 'topic-set' if topic_set_id is not None else "object-set"
    print("Starting synthesis stage for " + set_id)
    ts_config = config.config_subset('content-set/topic-set[topic-set-id="{tsid}"]'.format(tsid=set_id)
    ) if set_type == 'topic-set' else config.config_subset(
        'content-set/object-set[object-set-id="{osid}"]'.format(osid=set_id)
    )

    executed_steps = []
    if config.setting_exists('sources/sources-to-extract-content-from/include', ts_config):
        extract_output_dir = posixpath.join(posixpath.dirname(config.build_scripts[set_id][('extract', None)]), 'out')
        _build_extract_step(config=config,
                            set_id=set_id,
                            set_type=set_type,
                            output_dir=extract_output_dir)
        executed_steps.append('extract')

        if config.setting_exists("sources/authored-content/include", ts_config):
            executed_steps.append('merge')
            extracted_files = glob(extract_output_dir + '/*')
            source_files = []
            for y in config.settings("sources/authored-content/include", ts_config):
                source_files += (glob(y))
            merge_output_dir = posixpath.join(posixpath.dirname(config.build_scripts[set_id][('merge', None)]), 'out')
            _build_merge_step(config=config,
                              set_id=set_id,
                              set_type=set_type,
                              script=config.build_scripts[set_id][('merge', None)],
                              output_dir=merge_output_dir,
                              authored_files=source_files,
                              extracted_files=extracted_files)

    # Call the resolve step
    topic_files = []
    if 'merge' in executed_steps:
        topic_files = glob(merge_output_dir + '/*')
    elif 'extract' in executed_steps:
        topic_files = glob(extract_output_dir + '/*')
    else:
        for y in config.settings('sources/authored-content/include', ts_config):
            topic_files += [posixpath.normpath(x) for x in glob(y)]
    resolve_output_dir = posixpath.join(posixpath.dirname(config.build_scripts[set_id][('resolve', None)]),
                                        'out') if topic_set_id is not None else posixpath.join(
        config.content_set_build_dir, 'objects', set_id)
    _build_resolve_step(config=config,
                        set_id=set_id,
                        set_type=set_type,
                        script=config.build_scripts[set_id][('resolve', None)],
                        output_dir=resolve_output_dir,
                        topic_files=topic_files)

    # Call the toc step
    toc_output_dir = posixpath.join(config.content_set_build_dir, 'tocs')
    synthesis_files = glob(resolve_output_dir + '/*')
    try:
        _build_toc_step(config=config,
                        set_id=set_id,
                        set_type=set_type,
                        script=config.build_scripts[set_id][('toc', None)],
                        output_dir=toc_output_dir,
                        synthesis_files=synthesis_files)
    except KeyError:
        # There is no toc script, so skip it
        pass


    # Call the catalog step
    catalog_output_dir = posixpath.join(config.content_set_build_dir, 'catalogs')
    synthesis_files = glob(resolve_output_dir + '/*')
    try:
        _build_toc_step(config=config,
                        set_id=set_id,
                        set_type=set_type,
                        script=config.build_scripts[set_id][('catalog', None)],
                        output_dir=catalog_output_dir,
                        synthesis_files=synthesis_files)
    except KeyError:
        # There is no catalog script, so skip it
        pass


def _build_extract_step(config, set_id, set_type, output_dir):
    print("Building extract step for " + set_type + ' ' + set_id)
    script = config.build_scripts[set_id][('extract', None)]
    ts_config = config.config_subset('content-set/topic-set[topic-set-id="{tsid}"]'.format(tsid=set_id)
    ) if set_type == 'topic-set' else config.config_subset(
        'content-set/object-set[object-set-id="{osid}"]'.format(osid=set_id)
    )
    source_files = []
    for x in config.settings('sources/sources-to-extract-content-from/include', ts_config):
        source_files += (glob(x))
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, set_type + 's', set_id, 'extracted.flag')
    parameters = {'set-id': set_id,
                  'output-directory': output_dir,
                  'sources-to-extract-content-from': ';'.join(source_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_merge_step(config, set_id, set_type, script, output_dir, authored_files, extracted_files):
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, set_type + 's', set_id, 'merge.flag')
    parameters = {'set-id': set_id,
                  'output-directory': output_dir,
                  'authored-content-files': ';'.join(authored_files),
                  'extracted-content-files': ';'.join(extracted_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_resolve_step(config, set_id, set_type, script, output_dir, topic_files):
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, set_type + 's', set_id, 'resolve.flag')
    parameters = {'set-id': set_id,
                  'output-directory': output_dir,
                  'authored-content-files': ';'.join(topic_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_toc_step(config, set_id, set_type, script, output_dir, synthesis_files):
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, set_type + 's', set_id, 'toc.flag')
    parameters = {'set-id': set_id,
                  'output-directory': output_dir,
                  'synthesis-files': ';'.join(synthesis_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_catalog_step(config, set_id, set_type, script, output_dir, synthesis_files):
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, set_type + 's', set_id, 'catalog.flag')
    parameters = {'set-id': set_id,
                  'output-directory': output_dir,
                  'synthesis-files': ';'.join(synthesis_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_presentation_stage(config, topic_set_id):
    print("Starting presentation stage for " + topic_set_id)
    for presentation_type in [item[1] for item in config.build_scripts[topic_set_id] if item[0] == 'present']:
        link_output_dir = posixpath.join(
            posixpath.dirname(config.build_scripts[topic_set_id][('link', presentation_type)]), 'out')
        _build_link_step(config=config,
                         topic_set_id=topic_set_id,
                         script=config.build_scripts[topic_set_id][('link', presentation_type)],
                         output_dir=link_output_dir,
                         synthesis_files=[x.replace('\\', '/') for x in glob(
                             posixpath.join(posixpath.dirname(config.build_scripts[topic_set_id][('resolve', None)]),
                                            'out') + '/*')],
                         catalog_files=glob(
                             posixpath.join(config.content_set_build_dir, 'catalogs') + '/*'),
                         object_files=[x.replace('\\', '/') for x in
                                       glob(posixpath.join(config.content_set_build_dir, 'objects') + '/*/*')])

        present_output_dir = posixpath.join(
            posixpath.dirname(config.build_scripts[topic_set_id][('present', presentation_type)]), 'out')
        _build_present_step(config=config,
                            topic_set_id=topic_set_id,
                            script=config.build_scripts[topic_set_id][('present', presentation_type)],
                            output_dir=present_output_dir,
                            synthesis_files=[x.replace('\\', '/') for x in glob(
                                posixpath.join(posixpath.dirname(config.build_scripts[topic_set_id][('link', presentation_type)]),
                                               'out') + '/*')],
                            toc_files=glob(posixpath.join(config.content_set_build_dir, 'tocs') + '/*'),
                            object_files=[x.replace('\\', '/') for x in
                                          glob(posixpath.join(config.content_set_build_dir, 'objects') + '/*/*')])


def _build_link_step(config,
                     topic_set_id,
                     script,
                     output_dir,
                     synthesis_files,
                     catalog_files,
                     object_files):
    print("Building the link step for " + topic_set_id)
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, 'topic-sets', topic_set_id, 'catalog.flag')
    parameters = {'topic-set-id': topic_set_id,
                  'output-directory': output_dir,
                  'synthesis-files': ';'.join(synthesis_files),
                  'catalog-files': ';'.join(catalog_files),
                  'object-files': ';'.join(object_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_present_step(config,
                        topic_set_id,
                        script,
                        output_dir,
                        synthesis_files,
                        toc_files,
                        object_files):
    print("Building the present step for " + topic_set_id)
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, 'topic-sets', topic_set_id, 'catalog.flag')
    parameters = {'topic-set-id': topic_set_id,
                  'output-directory': output_dir,
                  'synthesis-files': ';'.join(synthesis_files),
                  'toc-files': ';'.join(toc_files),
                  'object-files': ';'.join(object_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)


def _build_formatting_stage(config, topic_set_id):
    print("Starting formatting stage for " + topic_set_id)
    for format_type in [item[1] for item in config.build_scripts[topic_set_id] if item[0] == 'format']:
        # FIXME: This should be calculated based on whether there is encoding to be done
        home_topic_set = config.setting('content-set/home-topic-set')
        if home_topic_set == topic_set_id:
            format_output_dir = config.content_set_output_dir
        else:
            format_output_dir = posixpath.join(config.content_set_output_dir, topic_set_id)
        presentation_type = config.setting(
            'content-set/output-formats/output-format[name="{ft}"]/presentation-type'.format(
                ft=format_type))

        presentation_type = config.setting(
            'content-set/output-formats/output-format[name="{ft}"]/presentation-type'.format(
                ft=format_type))

        try:
            presentation_files = [x.replace('\\', '/') for x in glob(
                posixpath.join(posixpath.dirname(config.build_scripts[topic_set_id][('present', presentation_type)]),
                               'out') + '/*')]
        except KeyError:
            exit(
                "Could not find presentation files of type " + presentation_type + " for format type " + format_type + ".")
        _build_format_step(config=config,
                           topic_set_id=topic_set_id,
                           format_type=format_type,
                           script=config.build_scripts[topic_set_id][('format', format_type)],
                           output_dir=format_output_dir,
                           presentation_files=presentation_files)


def _build_format_step(config,
                       topic_set_id,
                       format_type,
                       script,
                       output_dir,
                       presentation_files):
    infile = posixpath.join(config.content_set_config_dir, 'spfe-config.xml')
    outfile = posixpath.join(config.content_set_build_dir, 'topic-sets', topic_set_id, 'format.flag')
    parameters = {'topic-set-id': topic_set_id,
                  'output-directory': output_dir,
                  'presentation-files': ';'.join(presentation_files)}
    util.run_XSLT2(script=script, env=config.spfe_env, infile=infile, outfile=outfile, initial_template='main',
                   **parameters)

    # Copy images to output
    image_output_dir = os.path.join(output_dir, 'images')
    os.makedirs(image_output_dir, exist_ok=True)
    image_list = os.path.join(config.content_set_build_dir, 'topic-sets', topic_set_id, "image-list.txt")
    with open(image_list) as il:
        for image_file in il:
            shutil.copy(image_file.strip(), image_output_dir)

    # Copy support files
    style_output_dir = os.path.join(output_dir, 'style')
    os.makedirs(style_output_dir, exist_ok=True)
    for sf in config.settings(
            "content-set/output-formats/output-format[name='{0}']/support-files/include".format(format_type)):
        if os.path.isdir(sf):
            shutil.copytree(sf, style_output_dir)
        else:
            for file in glob(sf):
                shutil.copy(file, style_output_dir)


def _build_encoding_stage(config, topic_set_id):
    print("Starting encoding stage for " + topic_set_id)


def _build_encode_step(config):
    pass
