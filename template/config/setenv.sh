#!/bin/sh
# NOTE: /bin/sh is used in catalina.sh in Tomcat, which executes this script in the same shell, so make sure to avoid any e.g. Bash-isms


# Original content, as shipped with Liferay DXP:
#CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF8 -Djava.net.preferIPv4Stack=true -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false -Duser.timezone=GMT -Xmx1024m -XX:MaxMetaspaceSize=512m"
    
if [ -z "$CATALINA_OPTS" ]; then
    # CATALINA_OPTS is empty or not set =>
    #     use our recommended settings + allow appending using LIFERAY_JAVA_OPTS environment variable
    #
    # Note: The base settings were picked for JDK 8u171, with no Docker / containers support assumed

    # The parent directory will not be created by the JVM (if not existing) and GC log file would never be created as a result
    gc_logs_dir="$CATALINA_HOME/logs"
    mkdir -p ${gc_logs_dir}

    # The originals from above, except heap / meta sizing, which we will do separately;
    # $CATALINA_OPTS is not set before this file is evaluated, so no need to use it
    # in the beginning of the new value
    CATALINA_OPTS_ORIGINAL="-Dfile.encoding=UTF8 -Djava.net.preferIPv4Stack=true -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false -Duser.timezone=GMT"

    CATALINA_OPTS_BASIC="-server -XX:+AlwaysPreTouch"

    CATALINA_OPTS_GC_LOGGING_FILE="-Xloggc:$gc_logs_dir/gc.log -XX:NumberOfGCLogFiles=5 -XX:+UseGCLogFileRotation -XX:GCLogFileSize=20m -XX:+PrintGC -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintHeapAtGC -XX:+PrintGCCause -XX:+PrintTenuringDistribution -XX:+PrintReferenceGC -XX:+PrintAdaptiveSizePolicy"

    #CATALINA_OPTS_GC_LOGGING_STDOUT="-XX:+PrintGC -XX:+PrintGCCause"

    # GC - use parallel collector for newgen + CMS for oldgen
    CATALINA_OPTS_GC_YOUNG="-XX:+UseParNewGC -XX:NewSize=768m -XX:MaxNewSize=768m -XX:SurvivorRatio=6 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=15"

    CATALINA_OPTS_GC_OLD="-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=85 -XX:+CMSScavengeBeforeRemark -XX:+ScavengeBeforeFullGC -XX:+CMSConcurrentMTEnabled -XX:+CMSParallelRemarkEnabled -XX:+CMSCompactWhenClearAllSoftRefs"

    CATALINA_OPTS_METASPACE="-XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m"

    CATALINA_OPTS_HEAP="-Xms4g -Xmx4g"


    # For org.apache.catalina.security.SecurityListener in conf/server.xml
    # Not needed for Tomcat 9.0.7 and later, but we are on 9.0.6 for now.

    # Execute the same snippet here to have the same umask in the env as later set in the catalina.sh
    # BEGIN SNIPPET from stock catalina.sh;
    # Set UMASK unless it has been overridden
    if [ -z "$UMASK" ]; then
        UMASK="0027"
    fi
    umask $UMASK
    # END SNIPPET

    CATALINA_OPTS_UMASK="-Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`"


    CATALINA_OPTS="$CATALINA_OPTS_ORIGINAL $CATALINA_OPTS_BASIC $CATALINA_OPTS_GC_LOGGING_FILE $CATALINA_OPTS_GC_YOUNG $CATALINA_OPTS_GC_OLD $CATALINA_OPTS_METASPACE $CATALINA_OPTS_HEAP $CATALINA_OPTS_UMASK $LIFERAY_JAVA_OPTS"

else
    # CATALINA_OPTS is set and not empty =>
    #     prevent the startup and suggest possible options

    echo ""
    echo "Overriding recommended JVM parameters for Lifery DXP using CATALINA_OPTS environment variable is not allowed. Hint: Use LIFERAY_JAVA_OPTS instead."
    echo "If you really want to replace CATALINA_OPTS with your set of JVM parameters, you need to replace the whole '$CATALINA_HOME/bin/setenv.sh', for example using a custom Dockerfile."
    echo ""

    exit 1
fi

# No need to echo the CATALINA_OPTS - they are listed both by Tomcat on startup and also by DXP 7.1 in recent fixpacks
